%in each of these directories, convert the scan to a PCD
loadPaths;
donPrefix = '/home/charlie/Desktop/research/code/segmentation/c/distanceNormals/build/don %s 2 3 0.06 0.85 %s';
removeOutliersPrefix = '/home/charlie/Desktop/research/code/segmentation/c/removeStatOutliers/build/removeOutliers -i %s -o %s';
% add path to predict
addpath(genpath('/home/charlie/Desktop/research/code/utilities/'));
addpath(genpath('/home/charlie/Desktop/research/code/library/'));

%load your data structures
load model.mat
load svm.mat
load encoder.mat

parameters = struct();
parameters.pyramid = [1 2];

% paths to marshall data into
targetCarDir = '/home/charlie/Desktop/research/data/toyotascene/classification3d/car/';
targetNotDir = '/home/charlie/Desktop/research/data/toyotascene/classification3d/not/';
if (~exist(targetCarDir,'dir')) mkdir(targetCarDir); end;
if (~exist(targetNotDir,'dir')) mkdir(targetNotDir); end;

for i = 1:length(traindir)
	t = cell2mat(traindir(i));
    scanFile = getScanFile(t);
    %construct the savePath
    [x, y, z] = fileparts(scanFile);
    savePath = strcat(x,'/',y,'.pcd');
    cleanedPath = strcat(x,'/filtered.pcd');
    donDir = strcat(x,'/don/');
    %if the pcd does not exist then run scanToPCD
    %scanToPCD(scanFile, savePath);
    %now that you have the pcd, remove outliers if needed
%     removeOutliersCmd = sprintf(removeOutliersPrefix, savePath, cleanedPath);
%     disp(removeOutliersCmd);
%     system(removeOutliersCmd);
%     now we construct the don cmd
    donCmd = sprintf(donPrefix, cleanedPath, donDir);
    system(donCmd);
    %mk the cluster directory
    clusterDir = strcat(donDir,'cluster/');
    if (~exist(clusterDir,'dir')) 
        mkdir(clusterDir); 
    else
        %the clusters do exist
        purgeCmd = sprintf('rm %s',strcat(donDir,'classified/mat/*.pcd'));
        system(purgeCmd);
        purgeCmd = sprintf('rm %s',strcat(donDir,'classified/pcd/*.pcd'));
        system(purgeCmd);
    end;
    %now the cluster dir has the cluster files
    %just go the cluster dir and for each cluster pcd, convert to mat file
    classifyClusters(clusterDir, encoder, model, parameters);
    %next we want to reorganize the data into directories by class to
    %prepare for sharing with the NX servers where we will run
    %classificationPipeline
    matDir = fullfile(clusterDir,'/../classified/mat/');
    pcdDir = fullfile(clusterDir,'/../classified/pcd/');
    disp('merging classified');
    mergeClassified(pcdDir);
    disp('marshalling clusters');
    marshallClusters(matDir, targetCarDir, targetNotDir, i);
end

for i = 1:length(testdir)
	t = cell2mat(testdir(i));
    scanFile = getScanFile(t);
    %construct the savePath
    [x, y, z] = fileparts(scanFile);
    savePath = strcat(x,'/',y,'.pcd');
    cleanedPath = strcat(x,'/filtered.pcd');
    donDir = strcat(x,'/don/');
    %if the pcd does not exist then run scanToPCD
    %scanToPCD(scanFile, savePath);
    %now that you have the pcd, remove outliers if needed
%     removeOutliersCmd = sprintf(removeOutliersPrefix, savePath, cleanedPath);
%     disp(removeOutliersCmd);
%     system(removeOutliersCmd);
%     %now we construct the don cmd
    donCmd = sprintf(donPrefix, cleanedPath, donDir);
    system(donCmd);
    %mk the cluster directory
    clusterDir = strcat(donDir,'cluster/');
    if (~exist(clusterDir,'dir'))
        mkdir(clusterDir);
    else
        the clusters do exist
        purgeCmd = sprintf('rm %s',strcat(donDir,'classified/mat/*.pcd'));
        system(purgeCmd);
        purgeCmd = sprintf('rm %s',strcat(donDir,'classified/pcd/*.pcd'));
        system(purgeCmd);
    end;
    %now the cluster dir has the cluster files
    %just go the cluster dir and for each cluster pcd, convert to mat file
    classifyClusters(clusterDir, encoder, model, parameters);
    %next we want to reorganize the data into directories by class to
    %prepare for sharing with the NX servers where we will run
    %classificationPipeline
    matDir = fullfile(clusterDir,'/../classified/mat/');
    pcdDir = fullfile(clusterDir,'/../classified/pcd/');
    disp('merging classified');
    mergeClassified(pcdDir);
    disp('marshalling clusters');
    marshallClusters(matDir,targetCarDir, targetNotDir,i+length(traindir));
end