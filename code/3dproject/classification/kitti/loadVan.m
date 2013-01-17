rootSrcPath = 	'/mnt/neocortex/scratch/3dproject/data/KITTI/kitti_softmax_van';
rootSavePath =  '/mnt/neocortex/scratch/jumpbot/data/3dproject/9_18_12/vanpc';
rootFeaturePath = sprintf('%s/features',rootSavePath);

imgRootPath = sprintf('%s/patches', rootSrcPath);
imgTrainPath = sprintf('%s/train', imgRootPath);
imgTestPath = sprintf('%s/test', imgRootPath);
imgTrainCarPath = sprintf('%s/van', imgTrainPath);
imgTrainNegPath = sprintf('%s/not', imgTrainPath);
imgTestCarPath = sprintf('%s/van', imgTestPath);
imgTestNegPath = sprintf('%s/not', imgTestPath);

siftRootSavePath = 	sprintf('%s/sift', rootFeaturePath);
siftFeatTrainPath =     sprintf('%s/train_features', siftRootSavePath);
siftFeatTestPath =      sprintf('%s/test_features', siftRootSavePath);
siftFeatTrainCarPath = sprintf('%s/van', siftFeatTrainPath);
siftFeatTrainNegPath = sprintf('%s/not', siftFeatTrainPath);
siftFeatTestCarPath = sprintf('%s/van', siftFeatTestPath);
siftFeatTestNegPath = sprintf('%s/not', siftFeatTestPath);

hogRootSavePath = 	sprintf('%s/hog', rootFeaturePath);
hogFeatTrainPath =     sprintf('%s/train_features', hogRootSavePath);
hogFeatTestPath =      sprintf('%s/test_features', hogRootSavePath);
hogFeatTrainCarPath = sprintf('%s/van', hogFeatTrainPath);
hogFeatTrainNegPath = sprintf('%s/not', hogFeatTrainPath);
hogFeatTestCarPath = sprintf('%s/van', hogFeatTestPath);
hogFeatTestNegPath = sprintf('%s/not', hogFeatTestPath);

path1 = struct('srcPath', imgTrainCarPath, 'savePath', siftFeatTrainCarPath, 'class', 1, 'mode', 'train');
path2 = struct('srcPath', imgTrainNegPath, 'savePath', siftFeatTrainNegPath, 'class', 2, 'mode', 'train');

path3 = struct('srcPath', imgTestCarPath, 'savePath', siftFeatTestCarPath, 'class',1,'mode','test');
path4 = struct('srcPath', imgTestNegPath, 'savePath', siftFeatTestNegPath, 'class',2,'mode','test');

path5 = struct('srcPath', imgTrainCarPath, 'savePath', hogFeatTrainCarPath,'class',1,'mode','train');
path6 = struct('srcPath', imgTrainNegPath, 'savePath', hogFeatTrainNegPath, 'class',2,'mode','train');

path7 = struct('srcPath', imgTestCarPath, 'savePath', hogFeatTestCarPath, 'class',1,'mode','test');
path8 = struct('srcPath', imgTestNegPath, 'savePath', hogFeatTestNegPath, 'class',2,'mode','test');

siftPaths = [path1, path2, path3, path4];
hogPaths = [path5, path6, path7, path8];


%spinImages

matRootPath = sprintf('%s/mat', rootSrcPath);
matTrainPath = sprintf('%s/train', matRootPath);
matTestPath = sprintf('%s/test', matRootPath);
matTrainCarPath = sprintf('%s/van', matTrainPath);
matTrainNegPath = sprintf('%s/not', matTrainPath);
matTestCarPath = sprintf('%s/van', matTestPath);
matTestNegPath = sprintf('%s/not', matTestPath);

siRootSavePath = 	sprintf('%s/si', rootFeaturePath);
siFeatTrainPath =     sprintf('%s/train_features', siRootSavePath);
siFeatTestPath =      sprintf('%s/test_features', siRootSavePath);
siFeatTrainCarPath = sprintf('%s/van', siFeatTrainPath);
siFeatTrainNegPath = sprintf('%s/not', siFeatTrainPath);
siFeatTestCarPath = sprintf('%s/van', siFeatTestPath);
siFeatTestNegPath = sprintf('%s/not', siFeatTestPath);

path9 = struct('srcPath', matTrainCarPath, 'savePath', siFeatTrainCarPath,'class',1,'mode','train');
path10 = struct('srcPath', matTrainNegPath, 'savePath', siFeatTrainNegPath, 'class',2,'mode','train');
path11 = struct('srcPath', matTestCarPath, 'savePath', siFeatTestCarPath, 'class',1,'mode','test');
path12 = struct('srcPath', matTestNegPath, 'savePath', siFeatTestNegPath, 'class',2,'mode','test');

siPaths = [path9, path10, path11, path12];
