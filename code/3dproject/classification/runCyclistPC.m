%clear all; 
clc;
addpath(genpath('../library'));

%load up the parameters
parameters = loadParameters('./', 'run1.txt');

%img paths
loadCyclist();

%create your extractors
hog = extractorHOG(hogPaths, parameters.gs, parameters.ps);
sift = extractorSIFT(siftPaths, parameters.gs, parameters.ps);
si = extractorSI(siPaths, parameters.radius, parameters.imgW, parameters.minN);

kmeansTriSI = KMeansTri(parameters.numHidden,false);
kmeansTriSI.savepath = sprintf('%s/results/pc/encoder.mat', rootSavePath);

%stack them however you want to
stack1 = struct;
stack1.extractor = si;
stack1.encoder = kmeansTriSI;

%put the stacks together
stacks = [stack1];

%create your svm
svm = SVM_car;
svm.resultsPath = sprintf('%s/results/pc/', rootSavePath);
svm.savePath    = sprintf('%s/svm/pc/', rootSavePath);

if ~exist(svm.savePath, 'dir') mkdir(svm.savePath); end;
if ~exist(svm.resultsPath, 'dir') mkdir (svm.resultsPath); end;

%run the pipeline
classificationPipeline(stacks, svm, parameters);
