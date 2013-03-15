%this script returns all the cvpr segmentation results to their
%corresponding directories
%% routine imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%% parameters
cvprsourceLocation = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/cvpr/ford/segmentation/ucm15/';
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test/';

%% get all detection files, for each one, compose it's targetDirectory and execute a copy command
allSegmentationFiles = catalogue(cvprsourceLocation,'mat','obj');
for i = 1:length(allSegmentationFiles)
    cvprMat = cell2mat(allSegmentationFiles(i));
    [~,y,~] = fileparts(cvprMat);
    [results] = strsplit(y,'_');
    scene = cell2mat(results(1));
    cam = cell2mat(results(2));
    targetLocation = strcat(targetRoot,scene,'/cvpr_',cam,'.mat');
    disp(targetLocation);
    cpCmd = sprintf('cp %s %s',cvprMat,targetLocation);
    system(cpCmd);
end
