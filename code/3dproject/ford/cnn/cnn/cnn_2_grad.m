function [cost grad] = cnn_2_grad(I,Y,theta,b1,b2,fSize,numChannels,optConv)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias
% 
% b = theta(end);
% w = reshape(theta(1:end-1), [fSize numChannels]);

w2 = theta(end-1:end);
w1 = reshape(theta(1:end-2), [fSize 2]);

%% FEED FORWARD
a1 = zeros(size(Y,1),size(Y,2),2);
numChannels = 1;
a1(:,:,1) = double(conv2(gdouble(I),gdouble(rot90(w1(:,:,1),2)),'valid'));
a1(:,:,2) = double(conv2(gdouble(I),gdouble(rot90(w1(:,:,2),2)),'valid'));


a2 = a1(:,:,1).*w2(1)+a1(:,:,2).*w2(2);

err = Y.*a2;
comp = (err<1).*Y;

w2grad(1) = -sum(vec(comp.*a1(:,:,1)));
w2grad(2) = -sum(vec(comp.*a1(:,:,2)));
w1grad(:,:,1) = -conv2(I,rot90(comp.*w2(1),2),'valid');
w1grad(:,:,2) = -conv2(I,rot90(comp.*w2(2),2),'valid');

cost = sum(vec(max(0,1-err)));

% for i=1:numChannels
%     if isempty(optConv)
%         wgrad(:,:,i) = -conv2(I(:,:,i),rot90(comp,2),'valid');
%     elseif optConv == 'J'
%         wgrad(:,:,i) = -double(conv2(gdouble(I(:,:,i)),gdouble(rot90(comp,2)),'valid'));
%     elseif optConv == 'I'
%         wgrad(:,:,i) = -conv2_ipp(I(:,:,i),rot90(comp,2),'valid');
%     end
% end
% bgrad = -sum(comp(:));
% cost = sum(vec(max(0,1-err)));% + lambda*sum(w(:).*w(:))/2;
grad = [w1grad(:) ; w2grad(:)];
% grad = [wgrad(:) ; bgrad];

function x = vec(y)
x = y(:);

