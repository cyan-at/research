function [cost wgrad bgrad] = cnn_color_gradient(I,Y,w,b,fSize,lambda)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias

% b = theta(end-2:end);
% w = reshape(theta(1:end-3), [fSize 3]);

a = 0;
for i=1:3
    a = a+double(conv2(gdouble(I(:,:,i)),gdouble(rot90(w(:,:,i),2)),'valid')+b(i));
end

err = Y.*a;
comp = (err<1).*Y;
wgrad = zeros([fSize 3]);
for i=1:3
    wgrad(:,:,i) = -double(conv2(gdouble(I(:,:,i)),gdouble(rot90(comp,2)),'valid'));
end
bgrad = zeros(3,1);
for i=1:3
    bgrad(i) = -sum(comp(:));
end
cost = sum(vec(max(0,1-err))) + lambda*sum(w(:).*w(:))/2;

% grad = [wgrad(:) ; bgrad];

function x = vec(y)
x = y(:);

