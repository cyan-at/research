%this script is to test mapping algorithm from 3d point cloud to 2d pixels
folder = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/Scan1001/';
scanFile = strcat(folder,'Scan1001.mat');
%construct the n x 5 matrix for Cam 0
[pc, rgb, idx] = grabRGB(scanFile,folder);
%rgbs is a n x 3 array
saveName = strcat(folder,'withrgb.pcd');
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/utilities/matlab/mat2pcd/';
disp('writing to pcd');
mat2pcdrgb(pc, rgb, idx, saveName);
combined = [pc(idx,:),rgb(idx,:)];
save('combined.mat','combined');