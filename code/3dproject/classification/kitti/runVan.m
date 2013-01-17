%clear all; 
clc;
addpath(genpath('../library'));

%load up the parameters
parameters = loadParameters('./', 'run1.txt');

%img paths
loadVan();

%create your extractors
hog = extractorHOG(hogPaths, parameters.gs, parameters.ps);
sift = extractorSIFT(siftPaths, parameters.gs, parameters.ps);
si = extractorSI(siPaths, parameters.radius, parameters.imgW, parameters.minN);

%create your encoders
% kmeans = KMeansHard(parameters.numHidden,false);
% kmeans.savepath = sprintf('%s/encoder.mat', rootSavePath);

kmeansTri = KMeansTri(parameters.numHidden,false);
kmeansTri.savepath = sprintf('%s/encoder.mat', rootSavePath);

%stack them however you want to
stack1 = struct;
stack1.extractor = hog;
stack1.encoder = kmeansTri;

%put the stacks together
stacks = [stack1];

%create your svm
svm = SVM_car;
svm.resultsPath = sprintf('%s/results', rootSavePath);
svm.savePath    = sprintf('%s/svm', rootSavePath);

if ~exist(svm.savePath, 'dir') mkdir(svm.savePath); end;
if ~exist(svm.resultsPath, 'dir') mkdir (svm.resultsPath); end;

%run the pipeline
classificationPipeline(stacks, svm, parameters);
