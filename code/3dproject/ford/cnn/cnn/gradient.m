function [cost wgrad bgrad] = gradient(I,Y,w,b,lambda)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias
a = filter2(gdouble(w),gdouble(I),'valid')+b;

err = Y.*a;
comp = (err<1).*Y;
wgrad = -filter2(gdouble(comp),gdouble(I),'valid');
bgrad = -sum(comp(:));
cost = sum(vec(max(0,1-err))) + lambda*sum(w(:).*w(:))/2;

function x = vec(y)
x = y(:);

