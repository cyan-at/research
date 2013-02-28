%in each of these directories, convert the scan to a PCD
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
donPrefix = strcat(researchPath,'segmentation/c/distanceNormals/build/don %s 2 3 0.06 0.85 %s');
removeOutliersPrefix = strcat(researchPath,'segmentation/ford/c/removeStatOutliers/build/removeOutliers -i %s -o %s');
removeGroundPrefix = strcat(researchPath,'segmentation/ford/c/removeGround/build/remove %s %s');
euclideanPrefix = strcat(researchPath,'segmentation/ford/c/euclidean/build/euclidean -i %s -o %s -d 0.5');

%more parameters
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
trains =    catalogue(trainRoot,'folder');
tests =      catalogue(testRoot,'folder');

q = length(trains);
for i = 1:15
    %these are folders, for each folder 
    scanFolder = cell2mat(trains(i)); disp(scanFolder);

    %remove outliers
    disp('removing outliers');
    scanPCD = strcat(trainRoot,scanFolder,'/ford.pcd');
    cleanedPath = strcat(trainRoot,scanFolder,'/filtered.pcd');
    removeOutliersCmd = sprintf(removeOutliersPrefix, scanPCD, cleanedPath);
    system(removeOutliersCmd);
    
    %remove ground using naive
    disp('removing ground');
    nogroundPath = strcat(trainRoot,scanFolder,'/withoutground.pcd');
    removegroundCmd = sprintf(removeGroundPrefix, cleanedPath, nogroundPath);
    system(removegroundCmd);
    
    disp('cleaning up again');
    removeOutliersCmd = sprintf(removeOutliersPrefix, nogroundPath, nogroundPath);
    system(removeOutliersCmd);
    
    %get clusters using euclidean
    disp('getting clusters');
    clusterDir = strcat(trainRoot,scanFolder,'/clusters/'); 
    if (exist(clusterDir,'dir')); system(sprintf('rm -rf %s', clusterDir)); end;
    if (~exist(clusterDir,'dir')); mkdir(clusterDir); end;
    euclideanCmd = sprintf(euclideanPrefix,nogroundPath,clusterDir);
    system(euclideanCmd);
end
% 
% q = length(tests);
% for i = 1:q
%     %these are folders, for each folder 
%     scanFolder = cell2mat(tests(i)); disp(scanFolder);
% 
%     %remove outliers
%     disp('removing outliers');
%     scanPCD = strcat(testRoot,scanFolder,'/ford.pcd');
%     cleanedPath = strcat(testRoot,scanFolder,'/filtered.pcd');
%     removeOutliersCmd = sprintf(removeOutliersPrefix, scanPCD, cleanedPath);
%     system(removeOutliersCmd);
%     
%     %remove ground using naive
%     disp('removing ground');
%     nogroundPath = strcat(testRoot,scanFolder,'/withoutground.pcd');
%     removegroundCmd = sprintf(removeGroundPrefix, cleanedPath, nogroundPath);
%     system(removegroundCmd);
%     
%     disp('cleaning up again');
%     removeOutliersCmd = sprintf(removeOutliersPrefix, nogroundPath, nogroundPath);
%     system(removeOutliersCmd);
%     
%     %get clusters using euclidean
%     disp('getting clusters');
%     clusterDir = strcat(testRoot,scanFolder,'/clusters/'); 
%     if (exist(clusterDir,'dir')); system(sprintf('rm -rf %s', clusterDir)); end;
%     if (~exist(clusterDir,'dir')); mkdir(clusterDir); end;
%     euclideanCmd = sprintf(euclideanPrefix,nogroundPath,clusterDir);
%     system(euclideanCmd);
% end