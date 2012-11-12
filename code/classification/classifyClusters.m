function classifyClusters(clusterLocation, encoder, model)
addpath(genpath('/home/charlie/Desktop/research/code/library/'));
% performs binary classification on segmentation results
% path is the location of the cluster pcd files
% first, convert them all to mat files
matDir = fullfile(clusterLocation,'/../mat/');
disp(matDir);
if (~exist(matDir,'dir'))
    mkdir(matDir);
end
% parameters
radius = 1;
imgW = 16;
minN = 10;

% load model, encoder
load model.mat
load svm.mat

d = dir(clusterLocation);
nameFolds = {d.name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    pcdFile = fullfile(clusterLocation,cell2mat(nameFolds(i)));
    % disp(pcdFile);
    pc = pcd2mat(pcdFile);
    [~,y,z] = fileparts(pcdFile);
    matFileName = fullfile(matDir,strcat(y,'.mat'));
    disp(matFileName);
    save(matFileName,'pc');
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
    pool = pooling(feat, encoder, parameters);
    % then apply them to trained models
    
    % save the pool
    save(matFileName,'pool');
end
end
