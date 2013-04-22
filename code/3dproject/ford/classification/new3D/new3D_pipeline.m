function new3D_pipeline(stacksArray, svm, pars, msg)
%imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

close all;
trainLabels = [];   trainFeatures = [];
testLabels = [];    testFeatures = [];
matlabpool open 4; %run this line to open up multiple cores
%run through each stack and extract and encode
parfor i = 1:size(stacksArray,2)
    %run through each stack of extractors, encoders
    extractor = stacksArray(i).extractor;
    extractor.extractAll; %extract features
end
for i = 1:size(stacksArray,2)
    extractor = stacksArray(i).extractor;
    encoder = stacksArray(i).encoder;
    try
        load(encoder.savepath);
    catch
        disp('==================================================');
        fprintf('Training %s features', extractor.type);
        disp('==================================================');
        for j = 1:length(extractor.pathStructArray)
            %in each of the feature paths we look for the parameters for
            %information
            srcPath = extractor.pathStructArray(j).savePath;
            srcPath = strcat(srcPath, '/');
            parameters = loadParameters(srcPath);
            %check if that is a 'train' features
            if (strcmp(parameters.mode,'train'))
                %collecting features into a big file
                imagesPerClass = 80;
                batchSize = 100;
                %we want to collect up 50 128 x 1 vectors x 100 images
                %so our features matrix will be 128x20000
                features = collectFeatures(srcPath, imagesPerClass, batchSize, true);
                %train on those features
                encoder.train(features);
            end
        end
        save(encoder.savepath, 'encoder');
    end
    %after training the encoder, compute activations and pair with labels
    for j = 1:length(extractor.pathStructArray)
        srcPath = extractor.pathStructArray(j).savePath;
        srcPath = strcat(srcPath, '/');
        parameters = loadParameters(srcPath);
        [features, labels] = featsAndLabels(encoder, srcPath, pars);
        %naive concatenating, but you can add your fancy multimodal
        %stuff here
        if (strcmp(parameters.mode, 'train'))
            trainFeatures = [trainFeatures, features];
            trainLabels = [trainLabels, labels];
        elseif (strcmp(parameters.mode, 'test'))
            testFeatures = [testFeatures, features];
            testLabels = [testLabels, labels];
        end
    end
end
matlabpool close; %close the multiple cores
%Run SVM
[acc, acc_cv, ~, pred_test, model, ~, raw_score_test] = svm.train(trainFeatures, trainLabels', testFeatures, testLabels');
svmSaveName = sprintf('%s/svm.mat', svm.savePath);
modelSaveName = sprintf('%s/model.mat', svm.savePath);
save(svmSaveName, 'svm'); %save the svm model
save(modelSaveName, 'model');
%compute average precision
testLabels = testLabels';
[rec, prec, ap] = compute_avgpc(testLabels,raw_score_test);
% plot the recall-precision curve
plotSvmResults(svm, prec, rec, ap, msg);
% Calculate true negative acc & true positive acc.
not_idx = find(testLabels == 2);
true_neg_acc = sum(testLabels(not_idx) == pred_test(not_idx)) / length(not_idx); disp(true_neg_acc);
car_idx = find(testLabels == 1);
true_pos_acc = sum(testLabels(car_idx) == pred_test(car_idx)) / length(car_idx); disp(true_pos_acc);

resultsName = sprintf('%s/results.txt', svm.resultsPath);
fileID = fopen(resultsName, 'w');
fprintf(fileID,'True Negative Accuracy: %4.2f\n', true_neg_acc);
fprintf(fileID,'True Positive Accuracy: %4.2f\n', true_pos_acc);
fprintf(fileID,'Acc: %4.2f\n', acc);
fprintf(fileID,'Acc CV: %4.2f\n', acc_cv);
fprintf(fileID,'**********************************************************\n');
fprintf(fileID,'\n');
fprintf(fileID,'/n/n***Reporting best threshold and average precision***\n');
fprintf(fileID,'average precision = %g\n',ap);
f = 2*(prec.*rec)./(prec+rec);
[maxf1, thresh_idx] = max(f);
fprintf(fileID,'best thresh = %g (f1=%g) with recall = %g, precision = %g\n',raw_score_test(thresh_idx),maxf1,rec(thresh_idx),prec(thresh_idx));
fclose(fileID);

disp('Done!');
end