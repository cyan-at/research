function [ activation ] = computeActivation( rbm, data )
%rbm is some object, with W, vbias, hbias, weights should be in (data
%dimension x numHidden)
%data is a data point of dimension (dimension x 1)
    activation = rbm.W' * data;
    
end

