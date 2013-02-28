%this code will run through the ford data set and copy things into working
%folders for DON, 3D segmentation, 2D segmentation, CNN, etc.
%all pointclouds
addpath(genpath('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/'));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
trains =    catalogue(trainRoot,'folder');
tests =      catalogue(testRoot,'folder');

disp('mapping trains');
for i = 15:length(trains)
    idx = cell2mat(trains(i)); disp(idx);
    [x,y,~] = fileparts(idx);
    %get the image number
    %create the working directory
    scanDir = strcat(trainRoot,y,'/');
    scanFile = strcat(scanDir, 'scan.mat');
    [pc, info, idx] = grabRGB2(scanFile,scanDir);
    %info is [r g b x y cam]
    disp('writing to pcd');
    rgb = info(idx,1).*(2^16)+info(idx,2).*(2^8)+info(idx,3);
    combined = [pc(idx,:),rgb,info(idx,:),repmat(i,length(idx),1)];
    %combined row is [x y z rgb r g b x y cam scan]
    saveName = strcat(scanDir,'ford.pcd');
    mat2pcdford(combined,saveName);
    %combined is now a n x 11 matrix [x y z r g b pixelx pixely cam]
end

disp('mapping tests');
for i = 1:length(tests)
    idx = cell2mat(tests(i)); disp(idx);
    [x,y,~] = fileparts(idx);
    %get the image number
    %create the working directory
    scanDir = strcat(testRoot,y,'/');
    scanFile = strcat(scanDir, 'scan.mat');
    [pc, info, idx] = grabRGB(scanFile,scanDir);
    %info is [r g b x y cam]
    disp('writing to pcd');
    rgb = info(idx,1).*(2^16)+info(idx,2).*(2^8)+info(idx,3);
    combined = [pc(idx,:),rgb,info(idx,:),repmat(i,length(idx),1)];
    %combined row is [x y z rgb r g b x y cam scan]
    saveName = strcat(scanDir,'ford.pcd');
    mat2pcdford(combined,saveName);
    %combined is now a n x 11 matrix [x y z rgb r g b pixelx pixely cam ith]
end