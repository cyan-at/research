addpath(genpath('../library'));
addpath('./RBM');
clc;
loadPaths(); %load the paths
extractor1 = extractorHOG(hogPaths,2,16);
extractor2 = extractorSIFT(siftPaths,17,14);
%% train RBM 1
%DBN part
try
    load('rbm1.mat');
    load('allFeatures1.mat');
catch
    matlabpool open 5;
        extractor1.extractAll();
    matlabpool close;

    allFeatures1 = [];
    for j = 1:length(extractor1.pathStructArray)
        srcPath = extractor1.pathStructArray(j).savePath;
        srcPath = strcat(srcPath, '/');
        parameters = loadParameters(srcPath);
        %check if that is a 'train' features
        if (strcmp(parameters.mode,'train'))
            %collecting features into a big file
            imagesPerClass = 80;
            batchSize = 100;
            features = collectFeatures(srcPath, imagesPerClass, batchSize, true);
            %train on those features
            allFeatures1 = [allFeatures1 features];
        end
    end
    save('allFeatures1.mat', 'allFeatures1');
    rbm1 = rbmFit(allFeatures1',1000,'verbose',true);
    %optional, run classification here
    save('rbm1.mat','rbm1');
end
%% train RBM 2
try
    load('rbm2.mat');
    load('allFeatures2.mat');
catch
    matlabpool open 5;
        extractor2.extractAll();
    matlabpool close;
    allFeatures2 = [];
    for j = 1:length(extractor2.pathStructArray)
        srcPath = extractor2.pathStructArray(j).savePath;
        srcPath = strcat(srcPath, '/');
        parameters = loadParameters(srcPath);
        %check if that is a 'train' features
        if (strcmp(parameters.mode,'train'))
            %collecting features into a big file
            imagesPerClass = 80;
            batchSize = 100;
            features = collectFeatures(srcPath, imagesPerClass, batchSize, true);
            %train on those features
            allFeatures2 = [allFeatures2 features];
        end
    end
    save('allFeatures2.mat', 'allFeatures2');
    rbm2 =rbmFit(allFeatures2',1000,'verbose',true);
    %optional, run classification here
    save('rbm2.mat','rbm2');
end
%% train the second layer RBM
%now we have two RBM's, each with weights of (featureDim x numHidden)
%we go through each mat file in the feature directory, and get the feaArr,
%which may be featureDim x numFeatures, and feed the features one by one
%into the RBM to compute the activation of the hidden units, and add it to
%the result for that mat file, so in the end, for one mat file, we get
%(numHidden x numFeatures)
%we do this for each mat file, and in the end we get 
%(numHidden x numFeaturesPerFile*numFiles)
%we do this for the other modality as well,
%(numHidden x numFeaturesPerFile*numFiles)
try
    load('secondLayerRBM.mat');
catch
    try
        load('allActivations.mat');
    catch
        try
            load('pools1.mat');
        catch
            disp('Collecting activations from rbm 1');
            pools1 = [];
            for j = 1:length(extractor1.pathStructArray)
                srcPath = extractor1.pathStructArray(j).savePath;
                srcPath = strcat(srcPath, '/');
                parameters = loadParameters(srcPath);
                %check if that is a 'train' features
                if (strcmp(parameters.mode,'train'))
                    %collecting features into a big file
                    imagesPerClass = 80;
                    cat = catalogue(srcPath,parameters);
                    upperbound = length(cat);
                    indexes = randi(upperbound,imagesPerClass,1);
                    for i = 1:length(indexes)
                        fprintf('.');
                        load(cell2mat(cat(indexes(i))));
                        %rbm1.W is 32 x 1000
                        %feat.feaArr is 32 * 196
                        activation = sigmoid(rbm1.W'*feat.feaArr); %1000 x 196

%                         activation = sigmoid(1/rbm1.sigma*bsxfun(@plus,rbm1.W'*feat,rbm1.hbias));
                        pool = pooling(feat,activation);
                        pools1 = [pools1, pool];
                    end
                    fprintf('\n');
                end
            end
            save('pools1.mat', 'pools1');
        end
        try
            load('pools2.mat');
        catch
            disp('Collecting activations from rbm 2');
            pools2 = [];
            for j = 1:length(extractor2.pathStructArray)
                srcPath = extractor2.pathStructArray(j).savePath;
                srcPath = strcat(srcPath, '/');
                parameters = loadParameters(srcPath);
                %check if that is a 'train' features
                if (strcmp(parameters.mode,'train'))
                    %collecting features into a big file
                    imagesPerClass = 80;
                    cat = catalogue(srcPath,parameters);
                    upperbound = length(cat);
                    indexes = randi(upperbound,imagesPerClass,1);
                    for i = 1:length(indexes)
                        fprintf('.');
                        load(cell2mat(cat(indexes(i))));
                        %rbm2.W is 128 x 1000
                        %feat.feaArr is 128 * numFeatures
                        activation = sigmoid(rbm2.W'*feat.feaArr); %1000 x numFeatures
%                         activation = sigmoid(1/rbm1.sigma*bsxfun(@plus,rbm1.W'*feat,rbm1.hbias));
                        pool = pooling(feat,activation);
                        pools2 = [pools2, pool];
                    end
                    fprintf('\n');
                end
            end
            save('pools2.mat','pools2');
        end
        %vertical concatenate
        allActivations = [pools1; pools2];
        %allActivations is (totalHiddenUnits x numFeatures*numObjs)
        %save the allActivations
        save('allActivations.mat','allActivations');
    end
    %now train the second layer rbm on allActivations
    secondLayerRBM = rbmFit(allActivations',1000,'verbose',true);
    save('secondLayerRBM.mat','secondLayerRBM'); %save the secondLayerRBM
end
%%

%we've finished the DBN, now we construct the Deep Autoencoder
%we have the weights for first layer rbms and second layer rbm

%Deep Autoencoder part
%initialize the weights
%secondLayerRBM.W is 2000 x 1000
%rbm1.W is 32 x 1000
%rbm2.W is 128 x 1000

beta = 5;
lambda = 3e-3;
sparsityParam = 0.035;

addpath /mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/starter/minFunc/

theta = [vec(rbm1.W') ; vec(rbm2.W') ; vec(secondLayerRBM.W') ; vec(secondLayerRBM.W)...
    ; vec(rbm1.W) ; vec(rbm2.W) ; vec(rbm1.b') ; vec(rbm2.b') ; vec(secondLayerRBM.b')...
    ; vec(secondLayerRBM.c') ; vec(rbm1.c') ; vec(rbm2.c')];
%theta = rand(1,4325160);

s = [size(rbm1.W') ; size(rbm2.W') ; size(secondLayerRBM.W') ; size(secondLayerRBM.W)...
    ;size(rbm1.W) ; size(rbm2.W) ; size(rbm1.b') ; size(rbm2.b') ; size(secondLayerRBM.b')...
    ; size(secondLayerRBM.c') ; size(rbm1.c') ; size(rbm2.c')];


%% verify the gradient
[cost grad] = deepAutoEncoderCost(theta, s, allFeatures1, allFeatures2,...
    beta,...
    lambda,...
    sparsityParam...
);
% numgrad = computeNumericalGradient( @(x) deepAutoEncoderCost(x, s, allFeatures1, allFeatures2,...
%     beta,...
%     lambda,...
%     sparsityParam), theta);
% numgrad = numgrad';
% diff = norm(numgrad-grad)/norm(numgrad+grad)

%% training deep auto encoder
options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % sparseAutoencoderCost.m satisfies this.
options.maxIter = 400;	  % Maximum number of iterations of L-BFGS to run 
options.display = 'on';
[opttheta, cost] = minFunc(@(x) deepAutoEncoderCost(x, s, allFeatures1, allFeatures2,...
    beta,...
    lambda,...
    sparsityParam), theta, options);
