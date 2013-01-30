%this code will run through the ford data set and apply 3D segmentation to
%all pointclouds
dataRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/';
scansDir = strcat(dataRoot,'SCANS');
scans = cataloque(scansDir,'mat');
for i = 1:length(scans)
%create a directory, storing the image and the scan and the pcd file
scanFile = cell2mat(scans(i));
%extract the numbers from the scanFile name
%for every scan file, get the scan file

%make a pcd file

%apply DON pipeline on the pointcloud

%
end