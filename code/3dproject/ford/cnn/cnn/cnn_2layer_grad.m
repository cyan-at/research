% function [cost w1grad w2grad bgrad] = cnn_2layer_grad(I,Y,w1,w2,b,numHidden,fSize,numChannels,optConv)
function [c grad] = cnn_2layer_grad(IMAGES,YI,theta,numHidden,fSize,lambda)

% trying with gray scaled images first
% I is an image
% w is a filter (NxM)
% b is bias
% 
% % b = theta(end);
% % w = reshape(theta(1:end-1), [fSize numChannels]);

b = theta(end-1:end);
w2 = theta(end-1-numHidden:end-2);
w1 = reshape(theta(1:end-2-numHidden), [fSize numHidden]);

Bgrad = cell(length(YI),1);
W1grad = cell(length(YI),1);
W2grad = cell(length(YI),1);
cost = cell(length(YI),1);

for j=1:length(YI)
    I = IMAGES{j};
    Y = YI{j};
    %% FEED FORWARD
    a1 = zeros(size(Y,1),size(Y,2),numHidden);
    a2 = 0;
    for i=1:numHidden
        a1(:,:,i) = double(conv2(gdouble(I),gdouble(rot90(w1(:,:,i),2)),'valid'))+b(1);
        a2 = a2 + a1(:,:,i).*w2(i) + b(2);
    end

    %% BACK PROP

    err = Y.*a2;
    comp = (err<1).*Y;

    W2grad{j} = zeros(size(w2));
    W1grad{j} = zeros(size(w1));
    for i=1:numHidden
        W2grad{j}(i,1) = -sum(vec(comp.*a1(:,:,i)));
        W1grad{j}(:,:,i) = -conv2(I,rot90(comp.*w2(i),2),'valid');
    end
    Bgrad{j} = zeros(2,1);
    for i=1:numHidden
        Bgrad{j}(1,1) = Bgrad{j}(1,1) - sum(vec(comp*w2(i)));
    end
    Bgrad{j}(2,1) = -numHidden*sum(comp(:));

    cost{j} = sum(vec(max(0,1-err)));
end

w1grad = 0;
w2grad = 0;
bgrad = 0;
c = 0;
for i=1:length(YI)
    w1grad = W1grad{i}+w1grad;
    w2grad = W2grad{i}+w2grad;
    bgrad = Bgrad{i}+bgrad;
    c = cost{i}+c;
end
c = c+lambda*sum(w1(:).*w1(:))/2+lambda*sum(w2(:).*w2(:))/2;
w1grad = w1grad+lambda*w1;
w2grad = w2grad+lambda*w2;
grad = [w1grad(:) ; w2grad(:); bgrad(:)];

function x = vec(y)
x = y(:);

