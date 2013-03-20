%imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%load parameters
parameters = loadParameters('./', 'run1.txt');
loadCar();

%create your extractors
hog = extractorHOG(hogPaths, parameters.gs, parameters.ps);
si = extractorSI(siPaths, parameters.radius, parameters.imgW, parameters.minN);

kmeansTriSI = KMeansTri(parameters.numHidden,false);
kmeansTriSI.savepath = sprintf('%s/results/pc/', pwd);
if ~exist(kmeansTriSI.savepath,'dir') mkdir(kmeansTriSI.savepath); end;
kmeansTriSI.savepath = strcat(kmeansTriSI.savepath, 'siencoder.mat');

kmeansTriHOG = KMeansTri(parameters.numHidden,false);
kmeansTriHOG.savepath = sprintf('%s/results/hog/', pwd);
if ~exist(kmeansTriHOG.savepath,'dir') mkdir(kmeansTriHOG.savepath); end;
kmeansTriHOG.savepath = strcat(kmeansTriHOG.savepath, 'hogencoder.mat');

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
svm.resultsPath = sprintf('%s/results/hog/', pwd);
svm.savePath    = sprintf('%s/svm/hog/', pwd);

if ~exist(svm.savePath, 'dir') mkdir(svm.savePath); end;
if ~exist(svm.resultsPath, 'dir') mkdir (svm.resultsPath); end;

%run the pipeline
classificationPipeline(stacks, svm, parameters);