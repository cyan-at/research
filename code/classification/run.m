% driver script for classifyClusters
clc;
targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/');
targetNoCar = strcat(targetDir, 'nocar/');
modelLoc = '/home/charlie/Desktop/research/data/';
d = dir(targetHasCar);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    clusterLoc = strcat(cell2mat(nameFolds(i)), '/don/cluster/');
    disp(clusterLoc);
    classifyClusters(clusterLoc, modelLoc);
end
d = dir(targetNoCar);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    clusterLoc = strcat(cell2mat(nameFolds(i)), '/don/cluster/');
    disp(clusterLoc);
    classifyClusters(clusterLoc, modelLoc);
end