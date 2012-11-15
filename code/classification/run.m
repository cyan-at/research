% driver script for classifyClusters
clc;
targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/');
targetNoCar = strcat(targetDir, 'nocar/');
% load model, encoder
load model.mat
load svm.mat
load encoder.mat
% add path to predict
addpath(genpath('/home/charlie/Desktop/research/code/classification/svmlinear/'));
parameters = struct();
parameters.pyramid = [1 2];
d = dir(targetHasCar);
isub = [d(:).isdir];
carFolders = {d(isub).name}';
carFolders(ismember(carFolders,{'.','..'})) = [];
for i = 1:length(carFolders)
    clusterLoc = strcat(cell2mat(carFolders(i)), '/don/cluster/');
    clusterLoc = fullfile(targetHasCar,clusterLoc);
    disp(clusterLoc);
    classifyClusters(clusterLoc, encoder, model, parameters);
end
d = dir(targetNoCar);
isub = [d(:).isdir];
noCarFolders = {d(isub).name}';
noCarFolders(ismember(noCarFolders,{'.','..'})) = [];
for i = 1:length(noCarFolders)
    clusterLoc = strcat(cell2mat(noCarFolders(i)), '/don/cluster/');
    clusterLoc = fullfile(targetNoCar,clusterLoc);
    disp(clusterLoc);
    classifyClusters(clusterLoc, encoder, model, parameters);
end