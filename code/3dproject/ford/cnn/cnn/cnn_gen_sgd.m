% function [cost wgrad bgrad] = cnn_gen_grad(I,Y,w,b,fSize,numChannels,optConv)
function [cost grad] = cnn_gen_sgd(I,Y,theta,fSize,numChannels,optConv,lambda,num_images)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias
% 
b = theta(end);
w = reshape(theta(1:end-1), [fSize numChannels]);


    
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
%     comp = 2*max(0,1-Y.*a).*(err<1).*Y;
    comp = (err<1).*Y;
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
    
    wgrad = wgrad +lambda*w/num_images;
    cost = sum(vec(max(0,1-err))) + lambda*sum(w(:).*w(:))/2/num_images;

grad = [wgrad(:) ; bgrad];

function x = vec(y)
x = y(:);

