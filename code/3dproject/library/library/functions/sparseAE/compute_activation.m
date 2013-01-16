function Z = compute_activation(X,theta,pars)
%%% compute autoencoder activation
num_ch = pars.num_ch;
num_hid = pars.num_hid;
optenc = pars.optenc;

W = reshape(theta(1:num_ch*num_hid),num_ch,num_hid);
hbias = theta(num_ch*num_hid+1:(num_ch+1)*num_hid);

% compute activation
Z = bsxfun(@plus,W'*X,hbias);
if strcmp(optenc,'sigmoid'),
	Z = sigmoid(Z);
end

return;

function y = sigmoid(x)
y = 1./(1+exp(-x));
return;

