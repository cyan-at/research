% function [cost wgrad bgrad] = cnn_corr_grad(I,Y,w,b,fSize,numChannels,optConv)
function [cost grad] = cnn_corr_grad(IMAGES,YI,theta,fSize,numChannels,optConv,lambda)

% trying with gray scaled images first
% I is an image (PxQxnumChannels)
% w is a filter (NxMxnumChannels)
% b is bias (1x1)
% 
% HAVENT TESTED WITH IPP YET!
b = theta(end);
w = reshape(theta(1:end-1), [fSize numChannels]);

Bgrad = 0;
Wgrad = 0;
cost = 0;

for j=1:length(YI)
    
    I = IMAGES{j};
    Y = YI{j};
    
    a = 0;
    nw = zeros(numChannels,1);
    nI = zeros(size(Y,1),size(Y,2),numChannels);
    eps = 1e-7;

    % pre-compute w norm and I norm, add epsilon to prevent / 0
    for i=1:numChannels
        nw(i) = norm(vec(w(:,:,i)));
        if isempty(optConv)
            gI = I(:,:,i);
            nI(:,:,i) = sqrt( conv2( conv2(gI.^2,ones(size(w(:,:,i),1),1),'valid'),...
                    ones(1,size(w(:,:,i),2)), 'valid') ); 
        elseif optConv == 'J'
            gI = gdouble(I(:,:,i));
            nI(:,:,i) = sqrt( conv2( conv2(gI.^2,gdouble(ones(size(w(:,:,i),1),1)),'valid'),...
                    gdouble(ones(1,size(w(:,:,i),2))), 'valid') );
        elseif optConv == 'I'
            gI = I(:,:,i);
            nI(:,:,i) = sqrt( conv2_ipp( conv2_ipp(gI.^2,ones(size(w(:,:,i),1),1),'valid'),...
                    ones(1,size(w(:,:,i),2)), 'valid') ); 
        end
    end

    % compute the activation: sum(I *f w)/(norm(I)*norm(w))+b
    sub_act = zeros(size(Y,1),size(Y,2),numChannels);
    for i=1:numChannels
        corr = nw(i)*nI(:,:,i)+eps;
        if isempty(optConv)
            sub_act(:,:,i) = conv2(I(:,:,i),rot90(w(:,:,i),2),'valid')+b;
        elseif optConv == 'J'
            gI = gdouble(I(:,:,i));
            gw = gdouble(rot90(w(:,:,i),2));
            sub_act(:,:,i) = double(conv2(gI,gw,'valid'))+b;
        elseif optConv == 'I'
            sub_act(:,:,i) = conv2_ipp(I(:,:,i),rot90(w(:,:,i),2),'valid')+b;
        else
            error('undefined option');
        end
        a = a + (sub_act(:,:,i))./corr;
    end

    err = Y.*a;
    comp = (err<1).*Y;

    % compute wgrad, bgrad and cost
    wgrad = zeros([fSize numChannels]);
    for i=1:numChannels
        C = comp./nI(:,:,i);
        if isempty(optConv)
            gI = I(:,:,i);
            gcomp = rot90(C,2);
            wgrad(:,:,i) = (-nw(i)^2*double(conv2(gI,gcomp,'valid'))+sum(vec(C.*sub_act(:,:,i)))*w(:,:,i))/nw(i)^3;
        elseif optConv == 'J'
            gI = gdouble(I(:,:,i));
            gcomp = gdouble(rot90(C,2));
            wgrad(:,:,i) = (-nw(i)^2*double(conv2(gI,gcomp,'valid'))+sum(vec(C.*sub_act(:,:,i)))*w(:,:,i))/nw(i)^3;
        elseif optConv == 'I'
            gI = I(:,:,i);
            gcomp = rot90(C,2);
            wgrad(:,:,i) = (-nw(i)^2*double(conv2_ipp(gI,gcomp,'valid'))+sum(vec(C.*sub_act(:,:,i)))*w(:,:,i))/nw(i)^3;
        end
    end
    
    % bias gradient
    bgrad = 0;
    for i=1:numChannels
        corr = nw(i)*nI(:,:,i);
        bgrad = bgrad - sum(vec(comp./corr));
    end
    
    Wgrad = Wgrad + wgrad;
    Bgrad = Bgrad + bgrad;
    cost = cost + sum(vec(max(0,1-err)));
end

cost = cost + lambda*sum(w(:).*w(:))/2;
Wgrad = Wgrad + lambda*w;

grad = [Wgrad(:) ; Bgrad];

function x = vec(y)
x = y(:);

