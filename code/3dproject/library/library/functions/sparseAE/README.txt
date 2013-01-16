% SparseAutoEncoder
% written by Kihyuk Sohn

usage of codes:

model training
[opttheta,pars] = trainSparseAE(X,num_hid,l2reg,pbias,plambda,optenc,optdec,loss,gradcheck)
%	X  			: training examples, 		(dim) x (# examples)
%	num_hid		: number of hidden units 	(ex. 24)
%	l2reg		: l2 regularization 		(ex. 0.001)
%	pbias		: target sparsity			(ex. 0.01)
% 	plambda		: sparsity penalty			(ex. 1)
%	optenc		: encoding function 		('sigmoid' / 'linear')
% 	optdec		: decoding function			('sigmoid' / 'linear')
%	loss		: loss function				('l2' / 'ce')
%	gradcheck	: 1 (check gradient to debug) / 0 (otherwise)

compute activation
[Z] = compute_activation(X,theta,pars)
%	X		: examples (training/testing)
%	theta	: model parameters (opttheta from trainSparseAE.m)
%	pars	: model hyperparameters (pars from trainSparseAE.m)

ex)
[opttheta,pars] = trainSparseAE(X,24,0.0001,0.01,1,'sigmoid','linear','l2',0);
Z = compute_activation(X,opttheta,pars);	% Z is a hidden representation of X
