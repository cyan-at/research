% function [cost wgrad bgrad] = cnn_gen_grad(I,Y,w,b,fSize,numChannels,optConv)
function c = error_cost(IMAGES,YI,w,b,numChannels,optConv,lambda)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias
% 
% b = theta(end);
% w = reshape(theta(1:end-1), [fSize numChannels]);

cost = cell(length(YI),1);
correct = 0;
total = 0;

for j=1:length(YI)
    I = IMAGES{j};
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

    a(a>0) = 1;
    a(a<=0) = -1;
    correct = correct + sum(a(:) == Y(:));
    total = total + length(Y(:));
end

c = correct/total;

function x = vec(y)
x = y(:);

