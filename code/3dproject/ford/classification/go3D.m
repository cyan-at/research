%imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%load parameters
parameters = loadParameters('./', 'run1.txt');
loadExperiment1();

%create your extractors
si = extractorSI(siPaths, parameters.radius, parameters.imgW, parameters.minN);

kmeansTriSI = KMeansTri(parameters.numHidden,false);
kmeansTriSI.savepath = sprintf('%s/results/si/', pwd);
ensure(kmeansTriSI.savepath);
kmeansTriSI.savepath = strcat(kmeansTriSI.savepath, 'encoder.mat');

%stack them however you want to
stack1 = struct;
stack1.extractor = si;
stack1.encoder = kmeansTriSI;

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