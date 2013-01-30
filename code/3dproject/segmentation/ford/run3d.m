%this code will run through the ford data set and apply 3D segmentation to
%all pointclouds
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/functions/';
dataRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/';
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
if (~exist(scanFolderRoot,'dir')); mkdir(scanFolderRoot); end;
scansDir = strcat(dataRoot,'SCANS');
scans = catalogue(scansDir,'mat');
for i = 1:length(scans)
scanFile = cell2mat(scans(i));
%mkdir a directory with the name being this scan's name
[~,y,~] = fileparts(scanFile);
disp(y);
scanDir = strcat(scanFolderRoot,y);
if (~exist(scanDir,'dir')); mkdir(scanDir); end;
%load up the point cloud
pc = 
%make a pcd file

%apply DON pipeline on the pointcloud

%
end