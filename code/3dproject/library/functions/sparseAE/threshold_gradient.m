function grad = threshold_gradient(Z,eps,opt,a)
%%% soft thresholding inference
if ~exist('eps','var'), eps = 1e-4; end
if ~exist('opt','var'), opt = 'approx'; end
if ~exist('a','var'), a = 1; end

if strcmp(opt,'approx'),
    grad = 0.5*(1 + Z./sqrt(Z.^2 + eps)); % K x N
elseif strcmp(opt,'exact'),
    grad = zeros(size(Z));
    ind = Z >= 0;
    grad(ind) = 1;
elseif strcmp(opt,'softplus'),
	grad = sigmoid(a*Z);
end
return;

