%compute maps for all data
addpath(genpath('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/functions/'));
dataRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/';
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
if (~exist(scanFolderRoot,'dir')); mkdir(scanFolderRoot); end;
scansDir = strcat(dataRoot,'SCANS');
scans = catalogue(scansDir,'mat');

cleanup = true;
q = length(scans);
for i = 1:q
	scanFile = cell2mat(scans(i));
	%mkdir a directory with the name being this scan's name
	[~,y,~] = fileparts(scanFile);
    disp(sprintf('Started mapping %s',y));
	scanDir = strcat(scanFolderRoot,y,'/');
    scanFile = strcat(scanDir,y,'.mat');
    
    %cleanup: remove previous junk in folder
    if (cleanup)
    scanPCD = strcat(scanFolderRoot,y,'/',y,'.pcd');
    withPCD = strcat(scanFolderRoot,y,'/withrgb.pcd');
    filteredPCD = strcat(scanFolderRoot,y,'/filtered.pcd');
    nogroundPCD = strcat(scanFolderRoot,y,'/withoutground.pcd');
    combineFile = strcat(scanFolderRoot,y,'/new_combined.mat');
    addbackFile = strcat(scanFolderRoot,y,'/addback.mat');
    if (exist(scanPCD,'file')); system(sprintf('rm %s',scanPCD)); end;
    if (exist(withPCD,'file')); system(sprintf('rm %s',withPCD)); end;
    if (exist(filteredPCD,'file')); system(sprintf('rm %s',filteredPCD)); end;
    if (exist(nogroundPCD,'file')); system(sprintf('rm %s',nogroundPCD)); end;
    if (exist(combineFile,'file')); system(sprintf('rm %s',combineFile)); end;
    if (exist(addbackFile,'file')); system(sprintf('rm %s',addbackFile)); end;
    end

    %construct the n x 5 matrix for Cam 0
    [pc, info, idx] = grabRGB(scanFile,scanDir);
    %info is [r g b x y cam]
    disp('writing to pcd');
    rgb = info(idx,1).*(2^16)+info(idx,2).*(2^8)+info(idx,3);
    combined = [pc(idx,:),rgb,info(idx,:),repmat(i,length(idx),1)];
    %combined row is [x y z rgb r g b x y cam scan]
    saveName = strcat(scanDir,'ford.pcd');
    mat2pcdford(combined,saveName);
    %combined is now a n x 11 matrix [x y z r g b pixelx pixely cam]
end