researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath(strcat(researchPath,'ford/refinement/'));

% clear model; clear encoder;
% load(sprintf('%s/svm/hog/model.mat',pwd));
% load(sprintf('%s/results/hog/hogencoder.mat',pwd));
% im = imread('obj1673_2.png');
% parameters = loadParameters('./','run1.txt');
% [label score] = get2Dscore(im,model,encoder,parameters);

clear model; clear encoder;
load(sprintf('%s/kittimodel.mat',pwd));
load(sprintf('%s/kittiencoder.mat',pwd));
clear pointcloud; load('obj0323_7.mat');
parameters = loadParameters('./','run1.txt');
[label score] = get3Dscore(pointcloud,model,encoder,parameters);