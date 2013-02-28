% function [cost wgrad bgrad] = cnn_gen_grad(I,Y,w,b,fSize,numChannels,optConv)
function [c grad] = cnn_gen_grad(IMAGES,YI,theta,fSize,numChannels,optConv,lambda,optL2H)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias
% 
if exist('optL2H','var') == 0
    optL2H = 0;
end
b = theta(end);
w = reshape(theta(1:end-1), [fSize numChannels]);

Bgrad = cell(length(YI),1);
Wgrad = cell(length(YI),1);
cost = cell(length(YI),1);

for j=1:length(YI)
    I = double(IMAGES{j});
    Y = YI{j};
    
    a = 0;
    % numChannels = size(w,3);
    for i=1:numChannels
        if isempty(optConv)
            a = a+conv2(I(:,:,i),rot90(w(:,:,i),2),'valid')+b;
        elseif optConv == 'J'
            a = a+double(conv2(gdouble(I(:,:,i)),gdouble(rot90(w(:,:,i),2)),'valid')+b);
        elseif optConv == 'I'
            a = a+conv2_ipp(I(:,:,i),rot90(w(:,:,i),2),'valid')+b;
        else
            error('undefined option');
        end
    end

    err = Y.*a;
    if optL2H
        comp = 2*max(0,1-Y.*a).*(err<1).*Y;
    else
        comp = (err<1).*Y;
    end
    wgrad = zeros([fSize numChannels]);
    for i=1:numChannels
        if isempty(optConv)
            wgrad(:,:,i) = -conv2(I(:,:,i),rot90(comp,2),'valid');
        elseif optConv == 'J'
            wgrad(:,:,i) = -double(conv2(gdouble(I(:,:,i)),gdouble(rot90(comp,2)),'valid'));
        elseif optConv == 'I'
            wgrad(:,:,i) = -conv2_ipp(I(:,:,i),rot90(comp,2),'valid');
        end
    end
    bgrad = -numChannels*sum(comp(:));
    Wgrad{j} = wgrad;
    Bgrad{j} = bgrad;
    if optL2H
        cost{j} = sum(vec(max(0,1-err).^2));
    else
        cost{j} = sum(vec(max(0,1-err)));
    end
    
%     Wgrad = Wgrad + wgrad;
%     Bgrad = Bgrad + bgrad;
%     cost = cost + sum(vec(max(0,1-err)));
end

wg = 0;
bg = 0;
c = 0;
for i=1:length(YI)
    wg = Wgrad{i}+wg;
    bg = Bgrad{i}+bg;
    c = cost{i}+c;
end
c = c + lambda*sum(w(:).*w(:))/2;
wg = wg + lambda*w;
% w(w == 0) = 1e-7;
% c = c + lambda*sum(abs(w(:)));
% wg = wg + lambda*w./(abs(w)+1e-7);
grad = [wg(:) ; bg];

function x = vec(y)
x = y(:);

