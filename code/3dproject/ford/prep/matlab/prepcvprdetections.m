%prep 2d cvpr segmentation on ford train dataset
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/

%parameters
sourceRoot = '/mnt/neocortex/scratch/norrathe/scene_labeling_cvpr2012/ford/vis_results/ucm15/';
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test/';

%for each mat file, get the scene and move it to there
detections = catalogue(sourceRoot,'png');
for i = 1:length(detections)
    detection = cell2mat(detections(i)); disp(detection);
    [~,detectionName,~] = fileparts(detection);
    x = strsplit(detectionName,'_');
    sceneName = cell2mat(x(1));
    camName = cell2mat(x(2));
    targetName = strcat(targetRoot,sceneName,'/cvprdetection_',camName,'.png');
    cpCmd = sprintf('cp %s %s',detection,targetName);
    system(cpCmd);
end