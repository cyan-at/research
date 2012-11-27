%running a bimodal autoencoder
%setup
clc;
addpath(genpath('../../library'));
loadPaths(); %load the paths

matlabpool open 4;

%train RBM on HOG
hog = extractorHOG(hogPaths, 2, 16);
hog.extractAll();
hogFeatures = collectFeatures(hog.pathStructArray(1).savePath, 80, 100, true);
try
    load('hogRBM.mat');
catch
    hogRBM = RBM();
    hogRBM.train(hogFeatures);
    save('hogRBM.mat','hogRBM');
end

matlabpool close;

%we can visualize some reconstructions from the learned hog RBM.
load('obj0083.mat'); %load the image
C = imresize(img, [256, 256]);

[feaSet2] = calcHOGconcatenate(C, 16, 1);
feaArr2 = feaSet2.feaArr';
% fig1 = figure;
% im = visualizeHOGnew(reshape(feaArr2, [feaSet2.height,feaSet2.width,32]), gridX, gridY, ps);
% im = imresize(im, [256, 256]);
% 
% fig1 = figure;
% im = visualizeHOGnew(reshape(feat.feaArr

