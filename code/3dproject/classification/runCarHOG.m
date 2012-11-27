%clear all; 
clc;
addpath(genpath('../library'));

%load up the parameters
parameters = loadParameters('./', 'run1.txt');

%img paths
loadCar();

%create your extractors
hog = extractorHOG(hogPaths, parameters.gs, parameters.ps);
sift = extractorSIFT(siftPaths, parameters.gs, parameters.ps);
si = extractorSI(siPaths, parameters.radius, parameters.imgW, parameters.minN);

kmeansTriSI = KMeansTri(parameters.numHidden,false);
kmeansTriSI.savepath = sprintf('%s/results/pc/', rootSavePath);
if ~exist(kmeansTriSI.savepath,'dir') mkdir(kmeansTriSI.savepath); end;
kmeansTriSI.savepath = strcat(kmeansTriSI.savepath, 'encoder.mat');

kmeansTriHOG = KMeansTri(parameters.numHidden,false);
kmeansTriHOG.savepath = sprintf('%s/results/hog/', rootSavePath);
if ~exist(kmeansTriHOG.savepath,'dir') mkdir(kmeansTriHOG.savepath); end;
kmeansTriHOG.savepath = strcat(kmeansTriHOG.savepath, 'encoder.mat');


%stack them however you want to
stack1 = struct;
stack1.extractor = si;
stack1.encoder = kmeansTriSI;

stack2 = struct;
stack2.extractor = hog;
stack2.encoder = kmeansTriHOG;

%put the stacks together
stacks = [stack2];

%create your svm
svm = SVM_car;
svm.resultsPath = sprintf('%s/results/hog/', rootSavePath);
svm.savePath    = sprintf('%s/svm/hog/', rootSavePath);

if ~exist(svm.savePath, 'dir') mkdir(svm.savePath); end;
if ~exist(svm.resultsPath, 'dir') mkdir (svm.resultsPath); end;

%run the pipeline
classificationPipeline(stacks, svm, parameters);
