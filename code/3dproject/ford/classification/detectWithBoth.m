%detect cars using kitti model on ford dataset
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

% load model, encoder from ford
load ford_model.mat
fordmodel = model;
load ford_encoder.mat
fordencoder = encoder;

% load model, encoder from kitti
load kitti_model.mat
kittimodel = model;
load kitti_encoder.mat
kittiencoder = encoder;

% prep the encoders, the models
encoders = [fordencoder,kittiencoder];
models = [fordmodel,kittimodel];
names = {'ford','kitti'};

% add path to predict
svmlinearPath = strcat(researchPath,'classification/matlab/svmlinear/');
addpath(genpath(svmlinearPath));
parameters = loadParameters('./', 'run1.txt');

targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');

root = trainRoot;
fs = catalogue(root,'folder');
for i = 1:1
    scanFolder = strcat(root,cell2mat(fs(i))); %disp(scanFolder);
    clusterLoc = strcat(scanFolder,'/clusters/'); disp(clusterLoc);
    classifiedLoc = strcat(scanFolder,'/classified/');
    if exist(classifiedLoc,'dir'); 
        rmCmd = sprintf('rm -rf %s', classifiedLoc);
        system(rmCmd);
    end
    mkdir(classifiedLoc);
    classifyClusters(clusterLoc, encoders, models, names, parameters);
end

root = testRoot;
fs = catalogue(root,'folder');
for i = 1:1
    scanFolder = strcat(root,cell2mat(fs(i))); %disp(scanFolder);
    clusterLoc = strcat(scanFolder,'/clusters/'); disp(clusterLoc);
    classifiedLoc = strcat(scanFolder,'/classified/');
    if exist(classifiedLoc,'dir'); 
        rmCmd = sprintf('rm -rf %s', classifiedLoc);
        system(rmCmd);
    end
    mkdir(classifiedLoc);
    classifyClusters(clusterLoc, encoders, models, names, parameters);
end
