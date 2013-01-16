function [ y ] = sigmoid( x )
	% Sigmoid function.
	y = 1 ./ (1 + exp( -x ));
end 
