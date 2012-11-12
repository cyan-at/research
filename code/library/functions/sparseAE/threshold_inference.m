function [Z Zp] = threshold_inference(X,W,b,eps,opt,a)
%%% soft thresholding inference
if ~exist('eps','var'), eps = 1e-4; end
if ~exist('opt','var'), opt = 'approx'; end
if ~exist('a','var'), a = 1; end
Zp = bsxfun(@plus,W'*X,b);
if strcmp(opt,'approx'),
    Z = 0.5*(Zp + sqrt(Zp.^2+eps));
elseif strcmp(opt,'exact'),
    Z = max(abs(Zp),0);
elseif strcmp(opt,'softplus'),
	%Z = Zp + 1/a*log(1 + exp(-a*Zp));
	%ind = isinf(Z) > 0;
	%if ~isempty(ind), Z(ind) = 1; end
	Z = max(0,Zp) + 1/a*log(exp(-max(0,a*Zp)) + exp(a*Zp - max(0,a*Zp)));
end
return;
