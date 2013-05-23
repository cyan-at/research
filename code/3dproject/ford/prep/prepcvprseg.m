%prep 2d cvpr segmentation on ford train dataset
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/

sourceRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';

targetTrainRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprseg/train/';
targetTrainImgDir = strcat(targetTrainRoot,'images/');
ensure(targetTrainRoot); ensure(targetTrainImgDir);

targetTestRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprseg/test/';
targetTestImgDir = strcat(targetTestRoot,'images/');
ensure(targetTestRoot); ensure(targetTestImgDir);

trainRoot = strcat(sourceRoot,'train/');
testRoot = strcat(sourceRoot,'test/');

% root = trainRoot;
% fs = catalogue(root,'folder');
% for i = 1:length(fs)
%     workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
%     %for every workingpath, get all of the images
%     [~,sceneName,~] = fileparts(workingPath);
%     cams = catalogue(workingPath,'mat','cam');
%     for j = 1:length(cams)
%         camj = cell2mat(cams(j));
%         [x,camName,~] = fileparts(camj);
%         clear img;load(camj);
%         localName = strcat(x,'/',camName,'.png');
%         imwrite(img,localName,'png');
%         newName = sprintf('%s_%s.png',sceneName,camName);
%         newLocation = strcat(targetTrainImgDir,newName);
%         cpCmd = sprintf('cp %s %s', localName, newLocation);
%         system(cpCmd);
%     end
% end

root = testRoot;
fs = catalogue(root,'folder');
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    %for every workingpath, get all of the images
    [~,sceneName,~] = fileparts(workingPath);
    cams = catalogue(workingPath,'mat','cam');
    for j = 1:length(cams)
        camj = cell2mat(cams(j));
        [x,camName,~] = fileparts(camj);
        clear img;load(camj);
        localName = strcat(x,'/',camName,'.png');
        imwrite(img,localName,'png');
        newName = sprintf('%s_%s.png',sceneName,camName);
        newLocation = strcat(targetTestImgDir,newName);
        cpCmd = sprintf('cp %s %s', localName, newLocation);
        system(cpCmd);
    end
end