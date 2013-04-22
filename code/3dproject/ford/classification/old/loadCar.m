%imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

rootSrcPath = 	'/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification';
rootSavePath =  '/mnt/neocortex/scratch/jumpbot/data/3dproject/3_20_13';
ensure(rootSavePath);
rootFeaturePath = sprintf('%s/features',rootSavePath);

imgRootPath = sprintf('%s/twod', rootSrcPath);
imgTrainPath = sprintf('%s/train', imgRootPath);
imgTestPath = sprintf('%s/test', imgRootPath);
imgTrainCarPath = sprintf('%s/car', imgTrainPath);
imgTrainNegPath = sprintf('%s/not', imgTrainPath);
imgTestCarPath = sprintf('%s/car', imgTestPath);
imgTestNegPath = sprintf('%s/not', imgTestPath);

hogRootSavePath = 	sprintf('%s/hog', rootFeaturePath);
hogFeatTrainPath =     sprintf('%s/train_features', hogRootSavePath);
hogFeatTestPath =      sprintf('%s/test_features', hogRootSavePath);
hogFeatTrainCarPath = sprintf('%s/car', hogFeatTrainPath);
hogFeatTrainNegPath = sprintf('%s/not', hogFeatTrainPath);
hogFeatTestCarPath = sprintf('%s/car', hogFeatTestPath);
hogFeatTestNegPath = sprintf('%s/not', hogFeatTestPath);

path5 = struct('srcPath', imgTrainCarPath, 'savePath', hogFeatTrainCarPath,'class',1,'mode','train');
path6 = struct('srcPath', imgTrainNegPath, 'savePath', hogFeatTrainNegPath, 'class',2,'mode','train');
path7 = struct('srcPath', imgTestCarPath, 'savePath', hogFeatTestCarPath, 'class',1,'mode','test');
path8 = struct('srcPath', imgTestNegPath, 'savePath', hogFeatTestNegPath, 'class',2,'mode','test');
hogPaths = [path5, path6, path7, path8];

%spinImages

matRootPath = sprintf('%s/threed', rootSrcPath);
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
