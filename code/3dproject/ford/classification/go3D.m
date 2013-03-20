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
kmeansTriSI.savepath = sprintf('%s/results/si/', pwd);
if ~exist(kmeansTriSI.savepath,'dir') mkdir(kmeansTriSI.savepath); end;
kmeansTriSI.savepath = strcat(kmeansTriSI.savepath, 'encoder.mat');

kmeansTriHOG = KMeansTri(parameters.numHidden,false);
kmeansTriHOG.savepath = sprintf('%s/results/hog/', pwd);
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
stacks = [stack1];

%create your svm
svm = SVM_car;
svm.resultsPath = sprintf('%s/results/si/', pwd);
svm.savePath    = sprintf('%s/svm/si/', pwd);
ensure(svm.savePath);
ensure(svm.resultsPath);

%run the pipeline
classificationPipeline(stacks, svm, parameters);