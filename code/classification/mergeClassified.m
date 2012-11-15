%% this part of the code will call merge on all of the labelled clusters
clc;
targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/');
targetNoCar = strcat(targetDir, 'nocar/');
d = dir(targetHasCar);
isub = [d(:).isdir];
carFolders = {d(isub).name}';
carFolders(ismember(carFolders,{'.','..'})) = [];
merge_all_path = '/home/charlie/Desktop/research/code/utilities/c/mergePCD/test/mergeAll %s -o %s';
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

d = dir(targetNoCar);
isub = [d(:).isdir];
noCarFolders = {d(isub).name}';
noCarFolders(ismember(noCarFolders,{'.','..'})) = [];
for i = 1:length(noCarFolders)
    carpcds = strcat(cell2mat(noCarFolders(i)), '/don/classified/pcd/car_*.pcd');
    notpcds = strcat(cell2mat(noCarFolders(i)), '/don/classified/pcd/not_*.pcd');
    carInfiles = fullfile(targetNoCar,carpcds);
    notInfiles = fullfile(targetNoCar, notpcds);
    carNames = evalc(sprintf('ls %s', carInfiles));
    notNames = evalc(sprintf('ls %s', notInfiles));
    disp(carNames);
    disp(notNames);
end