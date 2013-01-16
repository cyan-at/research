function [cost, grad] = sparseAEcost_ST(theta,X,pars)
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
eps = pars.eps;
optpars = pars.optpars;
optenc = pars.optenc;
optsp = pars.optsp;
opt = pars.opt;
a = pars.a;
th = pars.th;

batchsize = size(X,2);

% unroll theta
W1 = reshape(theta(1:num_ch*num_hid),num_ch,num_hid);
if strcmp(optpars,'untied'),
    W2 = reshape(theta(num_ch*num_hid+1:2*num_ch*num_hid),num_ch,num_hid);
    hbias = theta(2*num_ch*num_hid+1:(2*num_ch+1)*num_hid);
    vbias = theta((2*num_ch+1)*num_hid+1:end);
else
    W2 = W1;
    hbias = theta(num_ch*num_hid+1:(num_ch+1)*num_hid);
    vbias = theta((num_ch+1)*num_hid+1:end);
end
cost = 0;
W1grad = zeros(size(W1));
W2grad = zeros(size(W2));
hgrad = zeros(size(hbias));
vgrad = zeros(size(vbias));

%% compute activation and reconstruction
% inference
if strcmp(optenc,'ST2'),
    [Z Zp] = soft_threshold_inference(X,W1,hbias,eps,th,opt);
    Zgrad = soft_threshold_gradient(Zp,eps,th,opt);
elseif strcmp(optenc,'ST1'),
    [Z Zp] = threshold_inference(X,W1,hbias,eps,opt,a);
    Zgrad = threshold_gradient(Zp,eps,opt,a);
end
% reconstruction
Xr = bsxfun(@plus,W2*Z,vbias);

%% compute cost and gradient (assume sigmoid encoding + linear decoding)
% recosntruction loss
cost = cost + 0.5*sum((Xr(:)-X(:)).^2)/batchsize;
Xd = Xr-X;
WXdZ = W2'*Xd.*Zgrad;

w1grad = WXdZ*X'/batchsize;   	% num_hid x num_ch
w2grad = Xd*Z'/batchsize;       % num_ch x num_hid
bgrad = sum(WXdZ,2)/batchsize;  % num_hid x 1
cgrad = sum(Xd,2)/batchsize;	% num_ch x 1

W1grad = W1grad + w1grad';
W2grad = W2grad + w2grad;
hgrad = hgrad + bgrad;
vgrad = vgrad + cgrad;

% weight l2reg
cost = cost + 0.5*l2reg*sum(W1(:).^2 + W2(:).^2);
W1grad = W1grad + l2reg*W1;
W2grad = W2grad + l2reg*W2;

% sparsity penalty: root mean squared
if strcmp(optsp,'rms'),
    mZ = sqrt(sum(Z.^2,2)/batchsize);
    Zgrad = bsxfun(@rdivide,Z.*Zgrad,mZ);
    Zgrad = -bsxfun(@times,Zgrad,pbias-mZ);
elseif strcmp(optsp,'l1'),
    if strcmp(optenc,'ST1'),
        mZ = sum(Z,2)/batchsize;
        Zgrad = -bsxfun(@times,Zgrad,pbias-mZ);
    elseif strcmp(optenc,'ST2'),
        tmpZ = sqrt(Z.^2 +eps);
        mZ = sum(tmpZ,2)/batchsize;
        Zgrad = bsxfun(@rdivide,Zgrad.*Z,tmpZ);
        Zgrad = -bsxfun(@times,Zgrad,pbias-mZ);
        clear tmpZ;
    end
end
cost = cost + plambda*0.5*sum((pbias-mZ).^2);

w1grad = plambda*Zgrad*X'/batchsize;
bgrad = plambda*sum(Zgrad,2)/batchsize;
W1grad = W1grad + w1grad';
hgrad = hgrad + bgrad;

if strcmp(optpars,'untied'),
    grad = [W1grad(:) ; W2grad(:); hgrad(:) ; vgrad(:)];
else
    W1grad = W1grad + W2grad;
    grad = [W1grad(:) ; hgrad(:) ; vgrad(:)];
end

return;
