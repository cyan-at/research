%clear all; 
clc;
addpath(genpath('../library'));
%load up the parameters for this run
parameters = loadParameters('./', 'run1.txt');
%extractor paths
toyotaScenePaths();
%create your extractors
hog = extractorHOG(hogPaths, parameters.gs, parameters.ps);
sift = extractorSIFT(siftPaths, parameters.gs, parameters.ps);
%create the encoders
kmeansTriSIFT = KMeansTri(parameters.numHidden,false);
kmeansTriSIFT.savepath = sprintf('%s/results/sift/', rootSavePath);
if ~exist(kmeansTriSIFT.savepath,'dir') mkdir(kmeansTriSIFT.savepath); end;
kmeansTriSIFT.savepath = strcat(kmeansTriSIFT.savepath, 'kmeansTriSIFT.mat');

kmeansTriHOG = KMeansTri(parameters.numHidden,false);
kmeansTriHOG.savepath = sprintf('%s/results/hog/', rootSavePath);
if ~exist(kmeansTriHOG.savepath,'dir') mkdir(kmeansTriHOG.savepath); end;
kmeansTriHOG.savepath = strcat(kmeansTriHOG.savepath, 'kmeansTriHOG.mat');

%stack them however you want to
stack1 = struct;
stack1.extractor = sift;
stack1.encoder = kmeansTriSIFT;

stack2 = struct;
stack2.extractor = hog;
stack2.encoder = kmeansTriHOG;

%put the stacks together
stacks = [stack1];

%create your svm
svm = SVM_car;
suffix = summarizeParameters(parameters);
svm.resultsPath = sprintf('%s/results/toyota_scene/%s', rootSavePath, suffix);
svm.savePath    = sprintf('%s/svm/toyota_scene/%s', rootSavePath, suffix);
if ~exist(svm.savePath, 'dir') mkdir(svm.savePath); end;
if ~exist(svm.resultsPath, 'dir') mkdir (svm.resultsPath); end;

%run the pipeline
classificationPipeline(stacks, svm, parameters);