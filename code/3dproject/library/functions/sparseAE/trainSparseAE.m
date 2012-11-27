function [opttheta,pars] = trainSparseAE(X,num_hid,l2reg,pbias,plambda,optenc,optdec,loss,gradcheck)
%%% train sparse autoencoder
%	X: num_ch x (# examples)
if ~exist('num_hid','var'), num_hid = 24; end;
if ~exist('l2reg','var'), l2reg = 0.0001; end;
if ~exist('pbias','var'), pbias = 0.01; end;
if ~exist('plambda','var'), plambda = 1; end;
if ~exist('optenc','var'), optenc = 'sigmoid'; end;
if ~exist('optdec','var'), optdec = 'linear'; end;
if ~exist('loss','var'), loss = 'l2'; end;
if ~exist('gradcheck','var'), gradcheck = 0; end;

%% hyperparameter setting
pars.num_ch = size(X,1);
pars.num_hid = num_hid;
pars.l2reg = l2reg;
pars.pbias = pbias;
pars.plambda = plambda;
pars.optenc = optenc;
pars.optdec = optdec;
pars.loss = loss;

%% initialize parameters
theta = initializeParameters(pars.num_ch, pars.num_hid);

%% gradient check
if gradcheck,
    addpath GradCheck;
    gradcheckidx = randsample(size(X,2),200);
    [diff,numgrad,testgrad] = GradCheck(@(p) sparseAEcost(p,X(:,gradcheckidx),pars), theta);
end

%% train model using minFunc
addpath /mnt/neocortex/scratch/kihyuks/library/minFunc/;
options.Method = 'lbfgs';
options.maxIter = 1000;   % Maximum number of iterations of L-BFGS to run
options.display = 'on';

[opttheta, ~] = minFunc( @(p) sparseAEcost(p, X, pars), theta, options);

return;
