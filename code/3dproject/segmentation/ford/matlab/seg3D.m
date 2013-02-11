%in each of these directories, convert the scan to a PCD
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
donPrefix = strcat(researchPath,'segmentation/c/distanceNormals/build/don %s 2 3 0.06 0.85 %s');
removeOutliersPrefix = strcat(researchPath,'segmentation/ford/c/removeStatOutliers/build/removeOutliers -i %s -o %s');
euclideanPrefix = strcat(researchPath,'segmentation/ford/c/euclidean/build/euclidean -i %s -o %s -d 0.5');
% add path to predict
%load your data structures
load model.mat
load svm.mat
load encoder.mat
parameters = struct();
parameters.pyramid = [1 2];
%more parameters
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
scans = catalogue(scanFolderRoot,'folder');
addpath '/mnt/neocortex/scratch/jumpbot/code/segmentation/matlab/removeGroundFromPCD/';
threshold = 0.3;
q = length(scans);
for i = 1:q
    %these are folders, for each folder 
    scanFolder = cell2mat(scans(i)); disp(scanFolder);

    %remove outliers
    disp('removing outliers');
    scanPCD = strcat(scanFolderRoot,scanFolder,'/ford.pcd');
    cleanedPath = strcat(scanFolderRoot,scanFolder,'/filtered.pcd');
    removeOutliersCmd = sprintf(removeOutliersPrefix, scanPCD, cleanedPath);
    system(removeOutliersCmd);
    
    %remove ground using naive
    disp('removing ground');
    nogroundPath = strcat(scanFolderRoot,scanFolder,'/withoutground.pcd');
    removeGroundFromPCD(cleanedPath,nogroundPath,threshold);

    %remove ground using RANSAC
    disp('removing ground using RANSAC');
    nogroundPath = strcat(scanFolderRoot,scanFolder,'/withoutground.pcd');
    
    
    %get clusters using euclidean
    disp('getting clusters');
    clusterDir = strcat(scanFolderRoot,scanFolder,'/clusters/'); 
    if (exist(clusterDir,'dir')); system(sprintf('rm -rf %s', clusterDir)); end;
    if (~exist(clusterDir,'dir')); mkdir(clusterDir); end;
    euclideanCmd = sprintf(euclideanPrefix,nogroundPath,clusterDir);
    system(euclideanCmd);
end