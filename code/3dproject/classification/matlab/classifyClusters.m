function classifyClusters(clusterLocation, encoder, model, parameters)
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'library/')));
% performs binary classification on segmentation results
% path is the location of the cluster pcd files
% first, convert them all to mat files
matDir = fullfile(clusterLocation,'/../classified/mat/');
pcdDir = fullfile(clusterLocation,'/../classified/pcd/');
% disp(matDir);
if (~exist(matDir,'dir'))
    mkdir(matDir);
end
if (~exist(pcdDir,'dir'))
    mkdir(pcdDir);
end
% parameters
radius = 1;
imgW = 16;
minN = 10;
d = dir(clusterLocation);
nameFolds = {d.name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
numCars = 0;
numNots = 0;
for i = 1:length(nameFolds)
    pcdFile = fullfile(clusterLocation,cell2mat(nameFolds(i)));
    % disp(pcdFile);
    pc = pcd2mat(pcdFile);
    [~,y,z] = fileparts(pcdFile);
    % then compute spin images on them
    feaArr = compSpinImages(pc', radius, imgW, minN);
    feaArr = reshape(feaArr,imgW*imgW,size(pc,2));
    feat.feaArr = single(feaArr);
    feat.width = size(feaArr,2);
    feat.height = size(feaArr,2);
    feat.x = [1:size(feaArr,2)];
    feat.y = [1:size(feaArr,2)];
    % save(matFileName,'feat');
    % then do pooling
    disp('computing pool');
    pool = pooling(feat, encoder, parameters);
    obj = struct();
    obj.pool = pool;
    obj.pc = pc;
    % save the pool
    % save(matFileName,'pool');
    % then apply them to trained models
    [label, ~, ~] = predict(double(1),sparse(pool),model,[],'col');
    % disp(label);
    if (label == 1)
        numCars = numCars + 1;
        name = strcat('car_',num2str(numCars));
    else
        numNots = numNots + 1;
        name = strcat('not_',num2str(numNots));
    end 
    % save the pool and point cloud under this name
    matFileName = fullfile(matDir,strcat(name,'.mat'));
    disp(matFileName);
    save(matFileName,'obj');
    % save the point cloud under that name
    newpcdFileName = fullfile(pcdDir,strcat(name,'.pcd'));
    cpCmd = sprintf('cp %s %s',pcdFile,newpcdFileName);
    disp(cpCmd);
    system(cpCmd);
end
end
