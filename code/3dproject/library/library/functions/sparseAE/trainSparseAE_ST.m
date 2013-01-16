function [opttheta,pars] = trainSparseAE_ST(X,num_hid,l2reg,pbias,plambda,optenc,optdec,optpars,loss,optsp,opt,a,th,gradcheck)
%%% train sparse autoencoder
%	X: num_ch x (# examples)
if ~exist('num_hid','var'), num_hid = 128; end;
if ~exist('l2reg','var'), l2reg = 0.0001; end;
if ~exist('pbias','var'), pbias = 0.01; end;
if ~exist('plambda','var'), plambda = 10; end;
if ~exist('optenc','var'), optenc = 'ST2'; end;
if ~exist('optdec','var'), optdec = 'linear'; end;
if ~exist('optpars','var'), optpars = 'untied'; end;
if ~exist('optsp','var'), optsp = 'l1'; end;
if ~exist('opt','var'), opt = 'approx'; end;
if ~exist('loss','var'), loss = 'l2'; end;
if ~exist('a','var'), a = 1; end;
if ~exist('th','var'), th = 1; end;
if ~exist('gradcheck','var'), gradcheck = 0; end;

%% hyperparameter setting
pars.num_ch = size(X,1);
pars.num_hid = num_hid;
pars.l2reg = l2reg;
pars.pbias = pbias;
pars.plambda = plambda;
pars.optenc = optenc;
pars.optdec = optdec;
pars.optpars = optpars;
pars.loss = loss;
pars.optsp = optsp;
pars.opt = opt;

pars.a = a;
pars.eps = 1e-4;    % relaxation variable
pars.th = th;        % threshold
%% initialize parameters
theta = initializeParameters(pars.num_ch, pars.num_hid, [], pars.optpars);

%% gradient check
if gradcheck,
    addpath /mnt/neocortex/scratch/kihyuks/library/GradCheck/;
    gradcheckidx = randsample(size(X,2),100);
    [diff,numgrad,testgrad] = GradCheck(@(p) sparseAEcost_ST(p,X(:,gradcheckidx),pars), theta);
end

%% train model using minFunc
addpath /mnt/neocortex/scratch/kihyuks/library/minFunc/;
options.Method = 'lbfgs';
options.maxIter = 1000;   % Maximum number of iterations of L-BFGS to run
options.display = 'on';

[opttheta, ~] = minFunc( @(p) sparseAEcost_ST(p, X, pars), theta, options);

return;
