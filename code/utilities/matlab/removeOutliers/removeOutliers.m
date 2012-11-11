%11/10/12
clc;
targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/');
targetNoCar = strcat(targetDir, 'nocar/');
% dir each directory and find the source.pcd in each directory
d = dir(targetHasCar);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    disp(nameFolds(i));
    a = strcat(cell2mat(nameFolds(i)),'/source.pcd');
    b = strcat(cell2mat(nameFolds(i)),'/cleaned.pcd');
    sourceFileLoc = fullfile(targetHasCar,a);
    %disp(sourceFileLoc);
    outputFileLoc = fullfile(targetHasCar,b);
    %disp(outputFileLoc);
    prefix = '/home/charlie/Desktop/research/code/segmentation/c/removeStatOutliers/build/removeOutliers -i %s -o %s';
    removeOutliersCmd = sprintf(prefix, sourceFileLoc, outputFileLoc);
    %disp(removeOutliersCmd);
    system(removeOutliersCmd);
end
d = dir(targetNoCar);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    disp(nameFolds(i));
    a = strcat(cell2mat(nameFolds(i)),'/source.pcd');
    b = strcat(cell2mat(nameFolds(i)),'/cleaned.pcd');
    sourceFileLoc = fullfile(targetNoCar,a);
    %disp(sourceFileLoc);
    outputFileLoc = fullfile(targetNoCar,b);
    %disp(outputFileLoc);
    prefix = '/home/charlie/Desktop/research/code/segmentation/c/removeStatOutliers/build/removeOutliers -i %s -o %s';
    removeOutliersCmd = sprintf(prefix, sourceFileLoc, outputFileLoc);
    %disp(removeOutliersCmd);
    system(removeOutliersCmd);
end