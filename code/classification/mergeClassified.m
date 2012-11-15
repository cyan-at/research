%% this part of the code will call merge on all of the labelled clusters
clc;
targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/');
targetNoCar = strcat(targetDir, 'nocar/');
d = dir(targetHasCar);
isub = [d(:).isdir];
carFolders = {d(isub).name}';
carFolders(ismember(carFolders,{'.','..'})) = [];
mergePrefix = '/home/charlie/Desktop/research/code/utilities/c/mergePCD/test/mergeAll';
for i = 1:length(carFolders)
    carpcds = strcat(cell2mat(carFolders(i)), '/don/classified/pcd/car_*.pcd');
    carpcdDir = fullfile(targetHasCar,strcat(cell2mat(carFolders(i)), '/don/classified/pcd/'));
    notpcds = strcat(cell2mat(carFolders(i)), '/don/classified/pcd/not_*.pcd');
    notpcdDir = fullfile(targetHasCar,strcat(cell2mat(carFolders(i)), '/don/classified/pcd/'));
    carInfiles = fullfile(targetHasCar,carpcds);
    notInfiles = fullfile(targetHasCar, notpcds);
    carNames = dir(carInfiles);
    notNames = dir(notInfiles);
    arguments = '';
    for i = 1:length(carNames)
        z = fullfile(carpcdDir,carNames(i).name);
        arguments = sprintf('%s %s', arguments, z);
    end
    carspcdLoc = fullfile(carpcdDir, 'cars.pcd');
    arguments = sprintf('%s -o %s',arguments, carspcdLoc);
    mergeCmd = sprintf('%s %s', mergePrefix, arguments);
    system(mergeCmd);
    arguments = '';
    for i = 1:length(notNames)
        z = fullfile(notpcdDir, notNames(i).name);
        arguments = sprintf('%s %s', arguments, z);
    end
    notpcdLoc = fullfile(notpcdDir, 'not.pcd');
    arguments = sprintf('%s -o %s',arguments, notpcdLoc);
    mergeCmd = sprintf('%s %s', mergePrefix, arguments);
    system(mergeCmd);
    x = 1;
end