function [cost, grad] = sparseAEcost(theta,X,pars)
%%%
%   X: num_ch x batchsize
% 	options -
%	encoding: sigmoid / linear
% 	decoding: sigmoid / linear
% 	loss	: l2norm / cross entropy
	
% parameters
num_ch = pars.num_ch;
num_hid = pars.num_hid;
l2reg = pars.l2reg;
pbias = pars.pbias;
plambda = pars.plambda;

optenc = pars.optenc;   % 'sigmoid','linear'
optdec = pars.optdec;   % 'sigmoid','linear'
loss = pars.loss;       % 'l2','ce'

batchsize = size(X,2);

% unroll theta
W = reshape(theta(1:num_ch*num_hid),num_ch,num_hid);
hbias = theta(num_ch*num_hid+1:(num_ch+1)*num_hid);
vbias = theta((num_ch+1)*num_hid+1:end);

cost = 0;
Wgrad = zeros(size(W));
hgrad = zeros(size(hbias));
vgrad = zeros(size(vbias));

%% compute activation and reconstruction
% inference
Z = bsxfun(@plus,W'*X,hbias);
if strcmp(optenc,'sigmoid'),
    Z = sigmoid(Z);
end

% reconstruction
Xr = bsxfun(@plus,W*Z,vbias);
if strcmp(optdec,'sigmoid'),
    Xr = sigmoid(Xr);
end

% some pars..
ZmZ = Z.*(1-Z);

%% compute cost and gradient (assume sigmoid encoding + linear decoding)
% recosntruction loss
if strcmp(loss,'l2'),
    cost = cost + 0.5*sum((Xr(:)-X(:)).^2)/batchsize;
    if strcmp(optdec,'sigmoid'),
        Xd = (Xr-X).*Xr.*(1-Xr);
    elseif strcmp(optdec,'linear'),
        Xd = Xr-X;
    end    
elseif strcmp(loss,'ce'),
    cost = cost + crossentropy(X(:),Xr(:))/batchsize;
    if strcmp(optdec,'sigmoid'),
        Xd = (1-X).*Xr-X.*(1-Xr);
    elseif strcmp(optdec,'linear'),
        Xd = (1-X)./(1-Xr)-X./Xr;
    end
end
if strcmp(optenc,'sigmoid'),
    WXdZ = W'*Xd.*ZmZ;
elseif strcmp(optenc,'linear'),
    WXdZ = W'*Xd;
end

w1grad = WXdZ*X'/batchsize;   	% num_hid x num_ch
w2grad = Xd*Z'/batchsize;       % num_ch x num_hid
bgrad = sum(WXdZ,2)/batchsize;  % num_hid x 1
cgrad = sum(Xd,2)/batchsize;	% num_ch x 1

Wgrad = Wgrad + w1grad' + w2grad;
hgrad = hgrad + bgrad;
vgrad = vgrad + cgrad;

% weight l2reg
cost = cost + 0.5*l2reg*sum(W(:).^2);
Wgrad = Wgrad + l2reg*W;

% sparsity penalty
mZ = sum(Z,2)/batchsize;
mZtmp = -pbias./mZ + (1-pbias)./(1-mZ);
cost = cost + plambda*sum((pbias*log(pbias./mZ)+(1-pbias)*log((1-pbias)./(1-mZ))));

Wgrad = Wgrad + plambda*bsxfun(@times,mZtmp,ZmZ*X'/batchsize)';
hgrad = hgrad + plambda*mZtmp.*(sum(ZmZ,2)/batchsize);

grad = [Wgrad(:) ; hgrad(:) ; vgrad(:)];

return;

function y = sigmoid(x)
y = 1./(1+exp(-x));
return;

function cost = crossentropy(x,xrec)
% x and xrec should be vectors, not matrices
cost = -sum(x.*log(xrec)+(1-x).*log(1-xrec));
return;
