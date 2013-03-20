%prep 2d cvpr segmentation on ford train dataset
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/refinement');
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/

sourceRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprseg/train/';
targetImgDir = strcat(targetRoot,'images/');
ensure(targetRoot); ensure(targetImgDir);
trainRoot = strcat(sourceRoot,'train/');
testRoot = strcat(sourceRoot,'test/');

root = trainRoot;
fs = catalogue(root,'folder');
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    %for every workingpath, get all of the images
    groundTruths = grabGroundTruths(workingPath);
    cams = catalogue(workingPath,'png','cam');
    [~,sceneName,~] = fileparts(workingPath);
    for j = 1:length(cams)
        %get ground truths in this cam
        c = cell2mat(cams(j)); load(c);
        [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
        bndboxes = groundTruths(groundTruths(:,1)==y,2:5);
        %load the image, and crop out the ground truth
        cropout = imcrop(img,[bndboxes(1), bnd
        newName = sprintf('%s_%s.png',sceneName,camName);
        newLocation = strcat(targetImgDir,newName);
        cpCmd = sprintf('cp %s %s', camj, newLocation);
        system(cpCmd);
    end
end