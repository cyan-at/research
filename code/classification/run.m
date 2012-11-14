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
%% this part of the code will call merge on all of the labelled clusters
merge_all_path = '/home/charlie/Desktop/research/code/utilities/c/mergePCD/test/mergeAll -i %s -o %s';
for i = 1:length(carFolders)
    carpcds = strcat(cell2mat(carFolders(i)), '/don/classified/pcd/car_*.pcd');
    notpcds = strcat(cell2mat(carFolders(i)), '/don/classified/pcd/not_*.pcd');
    carInfiles = fullfile(targetHasCar,carpcds);
    notInfiles = fullfile(targetHasCar, notpcds);
    carNames = evalc(sprintf('ls %s', carInfiles));
    notNames = evalc(sprintf('ls %s', notInfiles));
    disp(carNames);
    disp(notNames);
end

for i = 1:length(noCarFolders)
    carpcds = strcat(cell2mat(noCarFolders(i)), '/don/classified/pcd/car_*.pcd');
    notpcds = strcat(cell2mat(noCarFolders(i)), '/don/classified/pcd/not_*.pcd');
    carInfiles = fullfile(targetNoCar,carpcds);
    notInfiles = fullfile(targetNoCar, notpcds);
    mergeCarCmd = sprintf(merge_all_path, carpcds, 
    mergeNotCmd = 
    disp(clusterLoc);
    classifyClusters(clusterLoc, encoder, model, parameters);
end



