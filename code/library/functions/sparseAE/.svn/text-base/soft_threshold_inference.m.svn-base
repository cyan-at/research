function [Z Zp] = soft_threshold_inference(X,W,b,eps,th,opt)
%%% soft thresholding inference
if ~exist('eps','var'), eps = 1e-4; end
if ~exist('th','var'), th = 1; end
if ~exist('opt','var'), opt = 'approx'; end

Zp = bsxfun(@plus,W'*X,b);
if strcmp(opt,'approx'),
    Z = Zp + 0.5*(sqrt((Zp-th).^2+eps)-sqrt((Zp+th).^2+eps));
elseif strcmp(opt,'exact'),
    Z = sign(Zp).*max(abs(Zp)-th,0);
end

return;