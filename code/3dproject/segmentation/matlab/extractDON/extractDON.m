%11/10/12
% This script goes through the dataset and applies difference of normals
% segmentation on all code
clc;
targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/');
targetNoCar = strcat(targetDir, 'nocar/');
prefix = '/home/charlie/Desktop/research/code/segmentation/c/distanceNormals/build/don %s .2 2 0.25 0.75 %s';
% dir each directory and find the source.pcd in each directory
d = dir(targetHasCar);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    disp(nameFolds(i));
    b = strcat(cell2mat(nameFolds(i)),'/cleaned.pcd');
    c = strcat(cell2mat(nameFolds(i)),'/don/');
    pcdSource = fullfile(targetHasCar,b);
    targetDir = fullfile(targetHasCar, c);
    if (~exist(targetDir,'dir'))
        mkdir(targetDir);
        mkdir(fullfile(targetDir,'/cluster'));
    else
        system(sprintf('rm -rf %s', targetDir));
        mkdir(targetDir);
        mkdir(fullfile(targetDir,'/cluster'));
    end
    
    if (~exist(fullfile(targetDir, '/cluster'),'dir'))
        disp(fullfile(targetDir,'/cluster'));
        mkdir(fullfile(targetDir,'/cluster'));
    else
        system(sprintf('rm -rf %s', targetDir));
        mkdir(targetDir);
        mkdir(fullfile(targetDir,'/cluster'));
    end

    donCmd = sprintf(prefix, pcdSource, targetDir);
    disp(donCmd);
    system(donCmd);
end

d = dir(targetNoCar);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    disp(nameFolds(i));
    b = strcat(cell2mat(nameFolds(i)),'/cleaned.pcd');
    c = strcat(cell2mat(nameFolds(i)),'/don/');
    pcdSource = fullfile(targetNoCar,b);
    targetDir = fullfile(targetNoCar, c);
    if (~exist(targetDir,'dir'))
        mkdir(targetDir);
        mkdir(fullfile(targetDir,'/cluster'));
    else
    end
    if (~exist(fullfile(targetDir, '/cluster'),'dir'))
        disp(fullfile(targetDir,'/cluster'));
        mkdir(fullfile(targetDir,'/cluster'));
    end
    donCmd = sprintf(prefix, pcdSource, targetDir);
    disp(donCmd);
    system(donCmd);
end