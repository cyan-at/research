%this code will classify the clusters
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/classification/matlab/')));
addpath(genpath(strcat(researchPath,'/utilities/')));
addpath(genpath(strcat(researchPath,'/library/')));
%load your data structures
load model.mat
load svm.mat
load encoder.mat
parameters = struct();
parameters.pyramid = [1 2];
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
scans = catalogue(scanFolderRoot,'folder');
q = length(scans);
for i = 105:q
    %these are folders, for each folder 
    scanFolder = cell2mat(scans(i));
    disp(scanFolder);
    clusterDir = strcat(scanFolderRoot,scanFolder,'/clusters/'); if (~exist(clusterDir,'dir')); mkdir(clusterDir); end;
    classifyClusters(clusterDir, encoder, model, parameters);
    classifiedDir = fullfile(clusterDir,'/../classified/pcd/');
    mergeClassified(classifiedDir);
end
