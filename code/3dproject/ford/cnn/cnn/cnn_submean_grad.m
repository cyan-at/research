function [cost wgrad bgrad] = cnn_submean_grad(I,Y,w,b,fSize,numChannels,optConv)
% function [cost grad] = cnn_submean_grad(I,Y,theta,fSize,numChannels,optConv)
% trying with gray scaled images first
% I is an image (PxQxnumChannels)
% w is a filter (NxMxnumChannels)
% b is bias (1x1)
% 
% HAVENT TESTED WITH IPP YET!

% b = theta(end);
% w = reshape(theta(1:end-1), [fSize numChannels]);

a = 0;

% compute the activation: sum(I *f w)/(norm(I)*norm(w))+b
sub_act = zeros(size(Y,1),size(Y,2),numChannels);
size_w = size(w);
mean_I = zeros(size(sub_act));
for i=1:numChannels
    sum_w = sum(vec(w(:,:,i)));
    if isempty(optConv)
        mean_I(:,:,i) = conv2( conv2(I(:,:,i),ones(size_w(1),1),'valid'), ...
            ones(1,size_w(2)),'valid')/(size_w(1)*size_w(2));
        sub_act(:,:,i) = conv2(I(:,:,i),rot90(w(:,:,i),2),'valid')-sum_w*mean_I(:,:,i);
    elseif optConv == 'J'
        gI = gdouble(I(:,:,i));
        gw = gdouble(rot90(w(:,:,i),2));
        mean_I(:,:,i) = double(conv2( conv2(gI,gdouble(ones(size_w(1),1)),'valid'), ...
            gdouble(ones(1,size_w(2))),'valid')/(size_w(1)*size_w(2)));
        sub_act(:,:,i) = double(conv2(gI,gw,'valid')-sum_w*mean_I(:,:,i));
    elseif optConv == 'I'
        mean_I(:,:,i) = conv2_ipp( conv2_ipp(I(:,:,i),ones(size_w(1),1),'valid'), ...
            ones(1,size_w(2)),'valid')/(size_w(1)*size_w(2));
        sub_act(:,:,i) = conv2_ipp(I(:,:,i),rot90(w(:,:,i),2),'valid')-sum_w*mean_I(:,:,i);
    else
        error('undefined option');
    end
    a = a + sub_act(:,:,i) + b;
end

err = Y.*a;
comp = (err<1).*Y;

% compute wgrad, bgrad and cost
wgrad = zeros([fSize numChannels]);
for i=1:numChannels
    if isempty(optConv)
        gI = I(:,:,i);
        gcomp = rot90(comp,2);
        wgrad(:,:,i) = -double(conv2(gI,gcomp,'valid'))+sum(vec(comp.*mean_I(:,:,i)));
    elseif optConv == 'J'
        gI = gdouble(I(:,:,i));
        gcomp = gdouble(rot90(comp,2));
        wgrad(:,:,i) = -double(conv2(gI,gcomp,'valid'))+sum(vec(comp.*mean_I(:,:,i)));
    elseif optConv == 'I'
        gI = I(:,:,i);
        gcomp = rot90(comp,2);
        wgrad(:,:,i) = -double(conv2_ipp(gI,gcomp,'valid'))+sum(vec(comp.*mean_I(:,:,i)));
    end
end
bgrad = -numChannels*sum(comp(:));
cost = sum(vec(max(0,1-err)));

% grad = [wgrad(:) ; bgrad];

function x = vec(y)
x = y(:);

