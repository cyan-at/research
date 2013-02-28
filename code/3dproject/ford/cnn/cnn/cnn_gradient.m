function [cost grad] = cnn_gradient(I,Y,theta,fSize,lambda)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias

b = theta(end);
w = reshape(theta(1:end-1), fSize);

a = conv2(I,rot90(w,2),'valid')+b;
% a = filter2(gdouble(w),gdouble(I),'valid')+b;

err = Y.*a;
comp = (err<1).*Y;
% wgrad = -conv2_ipp(I,rot90(comp,2),'valid');
wgrad = -filter2(gdouble(comp),gdouble(I),'valid');
bgrad = -sum(comp(:));
cost = sum(vec(max(0,1-err))) + lambda*sum(w(:).*w(:))/2;

grad = [wgrad(:) ; bgrad];

function x = vec(y)
x = y(:);

