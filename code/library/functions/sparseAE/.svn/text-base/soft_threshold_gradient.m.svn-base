function grad = soft_threshold_gradient(Z,eps,th)
%%% soft thresholding inference
if ~exist('eps','var'), eps = 1e-4; end
if ~exist('th','var'), th = 1; end

grad = 1 + 0.5*(-(Z+th)./sqrt((Z+th).^2+eps) + (Z-th)./sqrt((Z-th).^2+eps)); % K x N
return;