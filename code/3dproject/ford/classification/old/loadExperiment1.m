%imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

rootSrcPath = 	'/mnt/neocortex/scratch/3dproject/data/experiments/experiment1/';
rootSavePath =  '/mnt/neocortex/scratch/jumpbot/data/3dproject/3_24_13/';
ensure(rootSavePath);
rootFeaturePath = sprintf('%s/features',rootSavePath);
ensure(rootFeaturePath);
%spinImages

matRootPath = sprintf('%s/mat', rootSrcPath);
matTrainPath = sprintf('%s/train', matRootPath);
matTestPath = sprintf('%s/test', matRootPath);
matTrainCarPath = sprintf('%s/car', matTrainPath);
matTrainNegPath = sprintf('%s/not', matTrainPath);
matTestCarPath = sprintf('%s/car', matTestPath);
matTestNegPath = sprintf('%s/not', matTestPath);

siRootSavePath = 	sprintf('%s/si', rootFeaturePath);
siFeatTrainPath =     sprintf('%s/train_features', siRootSavePath);
siFeatTestPath =      sprintf('%s/test_features', siRootSavePath);
siFeatTrainCarPath = sprintf('%s/car', siFeatTrainPath);
siFeatTrainNegPath = sprintf('%s/not', siFeatTrainPath);
siFeatTestCarPath = sprintf('%s/car', siFeatTestPath);
siFeatTestNegPath = sprintf('%s/not', siFeatTestPath);

path9 = struct('srcPath', matTrainCarPath, 'savePath', siFeatTrainCarPath,'class',1,'mode','train');
path10 = struct('srcPath', matTrainNegPath, 'savePath', siFeatTrainNegPath, 'class',2,'mode','train');
path11 = struct('srcPath', matTestCarPath, 'savePath', siFeatTestCarPath, 'class',1,'mode','test');
path12 = struct('srcPath', matTestNegPath, 'savePath', siFeatTestNegPath, 'class',2,'mode','test');
siPaths = [path9, path10, path11, path12];
