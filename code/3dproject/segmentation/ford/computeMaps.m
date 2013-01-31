%compute maps for all data
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/functions/';
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/utilities/matlab/mat2pcd/';
dataRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/';
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
if (~exist(scanFolderRoot,'dir')); mkdir(scanFolderRoot); end;
scansDir = strcat(dataRoot,'SCANS');
scans = catalogue(scansDir,'mat');
for i = 1:length(scans)
	scanFile = cell2mat(scans(i));
	%mkdir a directory with the name being this scan's name
	[~,y,~] = fileparts(scanFile);
    disp(sprintf('Started mapping %s',y));
	scanDir = strcat(scanFolderRoot,y,'/');
    scanFile = strcat(scanDir,y,'.mat');
    %construct the n x 5 matrix for Cam 0
    [pc, rgb, idx] = grabRGB(scanFile,scanDir);
    %rgbs is a n x 3 array
    saveName = strcat(scanDir,'withrgb.pcd');
    addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/utilities/matlab/mat2pcd/';
    disp('writing to pcd');
    mat2pcdrgb(pc, rgb, idx, saveName);
    combined = [pc(idx,:),rgb(idx,:)];
    save('combined.mat','combined');
end