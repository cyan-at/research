%this script returns all the cvpr segmentation results to their
%corresponding directories
%% routine imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%% parameters
cvprsourceRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprseg/';
cvprsourceRootTest = strcat(cvprsourceRoot,'test/segmentation/');
cvprsourceRootTrain = strcat(cvprsourceRoot,'train/segmentation/');

targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
segmentationlevels = {'08','10','15'};

%% get all detection files, for each one, compose it's targetDirectory and execute a copy command
for i = 1:length(segmentationlevels)
    level = strcat('ucm',cell2mat(segmentationlevels(i)));
    disp(level);
    sourceDir = strcat(cvprsourceRootTest,level);
    allSegmentationFiles = catalogue(sourceDir,'mat','obj');
    for j = 1:length(allSegmentationFiles)
        cvprMat = cell2mat(allSegmentationFiles(j));
        [~,y,~] = fileparts(cvprMat);
        [results] = strsplit(y,'_');
        scene = cell2mat(results(1));
        cam = cell2mat(results(2));
        targetLocation = strcat(targetRoot,'test/',scene,'/cvpr_',level,'_',cam,'.mat');
        disp(targetLocation);
        cpCmd = sprintf('cp %s %s',cvprMat,targetLocation);
        system(cpCmd);
    end
end

%% get all detection files, for each one, compose it's targetDirectory and execute a copy command
for i = 1:length(segmentationlevels)
    level = strcat('ucm',cell2mat(segmentationlevels(i)));
    disp(level);
    sourceDir = strcat(cvprsourceRootTrain,level);
    allSegmentationFiles = catalogue(sourceDir,'mat','obj');
    for j = 1:length(allSegmentationFiles)
        cvprMat = cell2mat(allSegmentationFiles(j));
        [~,y,~] = fileparts(cvprMat);
        [results] = strsplit(y,'_');
        scene = cell2mat(results(1));
        cam = cell2mat(results(2));
        targetLocation = strcat(targetRoot,'train/',scene,'/cvpr_',level,'_',cam,'.mat');
        disp(targetLocation);
        cpCmd = sprintf('cp %s %s',cvprMat,targetLocation);
        system(cpCmd);
    end
end
