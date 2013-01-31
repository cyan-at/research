%this code will run through the ford data set and apply 3D segmentation to
%all pointclouds
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/functions/';
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/utilities/matlab/mat2pcd/';
dataRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/';
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
if (~exist(scanFolderRoot,'dir')); mkdir(scanFolderRoot); end;
scansDir = strcat(dataRoot,'SCANS');
scans = catalogue(scansDir,'mat');
prefix = '/home/charlie/Desktop/research/code/segmentation/c/distanceNormals/build/don %s .2 2 0.25 0.75 %s';
start = false;
if (start)
for i = 1:length(scans)
	scanFile = cell2mat(scans(i));
	%mkdir a directory with the name being this scan's name
	[~,y,~] = fileparts(scanFile);
	scanDir = strcat(scanFolderRoot,y,'/');
	if (~exist(scanDir,'dir')); mkdir(scanDir); end;
	%load up the point cloud
	targetMatName = strcat(scanDir,y,'.mat');
	cpCmd = sprintf('cp %s %s', scanFile, targetMatName);
	system(cpCmd);
	%grab the ppm from the obj and copy it over to the scan directory
    clear SCAN; load(targetMatName); index = SCAN.image_index;
    cam0 = strcat(dataRoot,'IMAGES/Cam0/image0',num2str(index),'.ppm');
    cam1 = strcat(dataRoot,'IMAGES/Cam1/image0',num2str(index),'.ppm');
    cam2 = strcat(dataRoot, 'IMAGES/Cam2/image0',num2str(index),'.ppm');
    cam3 = strcat(dataRoot, 'IMAGES/Cam3/image0',num2str(index),'.ppm');
    cam4 = strcat(dataRoot, 'IMAGES/Cam4/image0',num2str(index),'.ppm');
    targetImgName0 = strcat(scanDir, 'image0.ppm');
	cpCmd = sprintf('cp %s %s', cam0, targetImgName0);
    system(cpCmd);	
    targetImgName1 = strcat(scanDir, 'image1.ppm');
	cpCmd = sprintf('cp %s %s', cam1, targetImgName1);    
    system(cpCmd);
    targetImgName2 = strcat(scanDir, 'image2.ppm');
	cpCmd = sprintf('cp %s %s', cam2, targetImgName2);
    system(cpCmd);	
    targetImgName3 = strcat(scanDir, 'image3.ppm');
	cpCmd = sprintf('cp %s %s', cam3, targetImgName3);
    system(cpCmd);
    targetImgName4 = strcat(scanDir, 'image4.ppm');
	cpCmd = sprintf('cp %s %s', cam4, targetImgName4);
    system(cpCmd);
	disp(y);
end
end
start = false;
if (start)
%%in this section we will extract pcl from every scan file and run DON
%%clustering
for i = 1:length(scans)
	scanFile = cell2mat(scans(i));
	%mkdir a directory with the name being this scan's name
	[~,y,~] = fileparts(scanFile);
	scanDir = strcat(scanFolderRoot,y,'/');
    targetMatName = strcat(scanDir,y,'.mat');
	%grab the ppm from the obj and copy it over to the scan directory
    clear SCAN; load(targetMatName);
    pc = SCAN.XYZ;
    targetPCDName = strcat(scanDir,y,'.pcd');
    mat2pcd(pc',targetPCDName);
	disp(y);
end
end
start = true
if (start)
%% In this section of code we will remove statistical outliers and extract DON from the PCD point clouds

end
