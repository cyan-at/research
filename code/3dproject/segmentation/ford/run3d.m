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
	scanDir = strcat(scanFolderRoot,y);
	if (~exist(scanDir,'dir')); mkdir(scanDir); end;
	%load up the point cloud
	targetMatName = strcat(scanDir,y,'.mat');
	cpCmd = sprintf('cp %s %s', scanFile, targetMatName);
	system(cpCmd);
	%grab the ppm from the obj and copy it over to the scan directory
	targetImgName = strcat(scanDir, 'image.ppm');
	cpCmd = sprintf('cp %s %s', obj.img, targetImgName);
	disp(targetImgName);
	system(cpCmd);	
	%make a pcd file
	%apply DON pipeline on the pointcloud
	
end