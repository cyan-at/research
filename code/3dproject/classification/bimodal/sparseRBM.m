function [RBM] = sparseRBM( numHidden, featureMatrix, name, pBias, pBiasLambda )
%SPARSERBM
addpath rbm/
%hyperparameters
if ~exist('pBias','var'), pBias = 0.01; end
if ~exist('pBias_lambda','var'), pBiasLambda = 3; end

%training sparseRBM
parameters = generateParameters(numHidden, pBias, pBiasLambda, name);
[~,~,RBM] = rbmFirstLayer(featureMatrix,parameters,'');
end

function p = generateParameters(numBases,pBias,pBiasLambda, dataSet)
if ~exist('numBases','var'), numBases = 1024; end;    % default: num_bases = 1024
if ~exist('pBias','var'), pBias = 1; end;               % default: pbias = 1

p.ws = 1;
p.es = p.ws;
p.num_hid = numBases;
p.optgmminit = 0;
p.opttfinit = 0;
p.optgpu = 0;
p.optjacket = 0;
p.opteps = 0;
p.optlambda = 0;
p.opthid = 0;
p.optsigma = 0;
p.optpbias = 0;
p.optsp = 'l2';

%path to save gmm & rbm parameters
p.gmmSavePath = '~/scratch/jumpbot/data/3dproject/8_22_12/run1/gmm';
p.savePath =    '~/scratch/jumpbot/data/3dproject/8_22_12/run1/savePath';
p.fdPath =      '~/scratch/jumpbot/data/3dproject/8_22_12/run1/fdPath';
p.dataPath =    '~/scratch/jumpbot/data/3dproject/8_22_12/run1/dataPath';

if ~exist(p.gmmSavePath, 'dir') mkdir(p.gmmSavePath); end;
if ~exist(p.savePath, 'dir') mkdir (p.savePath); end;
if ~exist(p.fdPath, 'dir') mkdir (p.fdPath); end;
if ~exist(p.dataPath, 'dir') mkdir (p.dataPath); end;
%other hyperparameters
p.dataSet = dataSet;
p.dataName = 'cars';
p.numTrials = 100;
p.momch = 4;
p.numVis = 128;
p.batchSize = 200;
p.pBias = pBias;
p.pBiasTar = pBias;
p.pBiasMin = pBias;
p.pBiasLambda = pBiasLambda;
p.sparsityLambda = 0;
p.stepSize = (p.pBiasLambda - p.sparsityLambda)/p.momch;

p.epsilon = 0.01;
p.l2reg = 1e-4;
p.l1reg = 0;
p.epsDecay = 0.01;
if p.optgmminit == 1, p.optsigma = 1; end
if p.optgmminit == 0, p.opthid = 0; p.optsigma = 0; p.optlambda = 0; p.opteps = 0; end
p.K_CD = 1;
p.C_sigm = 1;
end
