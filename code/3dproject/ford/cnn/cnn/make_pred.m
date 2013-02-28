function [ bndbox ] = make_pred( img, model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% Calculate activations.
P = 0;
optJacket = 0;
optIpp = 0;
I = img;
for i=1:size(model.W,3)
    
    if optJacket
        P = P+double(conv2(gdouble(I(:,:,i)),gdouble(rot90(model.W(:,:,i),2)),'valid')+model.b(i));
    elseif optIpp
        addpath /afs/umich.edu/user/h/o/honglak/Library/convolution/IPP-conv2-mex/
        P = P+conv2_ipp(I(:,:,i),rot90(model.W(:,:,i),2),'valid')+model.b(i);
    else
        P = P+conv2(I(:,:,i),rot90(model.W(:,:,i),2),'valid')+model.b(i);
    end
    
end

% Pick the high activations.

[r c] = find(P>0);



end

