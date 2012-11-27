function [cost,grad] = backProp(    data1,data2,...
                                    W1,b1,...
                                    W2,b2,...
                                    W3,b3,...
                                    W4,b4,...
                                    W5,b5,...
                                    W6,b6
                                )
%data1 and data2 are the collectedFeatures randsampled from patches
%dimensions of data1
%featureDim x numSamples

%rbm1W is pretrained weights from rbm 1
%rbm1W is 1000 x 32 (numHidden x featureDim)
%rbm1W * data1 => 1000 x numSamples
%b(1) is 1000 x 1

%secondLayerRBM.W is 2000 x 1000
%rbmW2 is 1000 x 128 (numHidden x featureDim)

% W5 = W3';
% W6 = W4';
% W7 = rbm1W';
% W8 = rbm2W';


% 0-0   0-0
%    \ /
%     0
%    / \
% 0-0   0-0

num_data1 = size(data1,2);
num_data2 = size(data2,2);
if num_data1 ~= num_data2
    error('number of data1 and data2 are different');
    return;
end

%feed forward
num_data = num_data1;
a1 = sigmoid(W1 * data1 + repmat(b1,1,num_data)); %numHidden x numSamples
a2 = sigmoid(W2 * data2 + repmat(b2,1,num_data)); %numHidden x numSamples
comb = [a1;a2]; 
a3 = sigmoid(W3 * comb + repmat(b3,1,num_data));
a4 = sigmoid(W4 * a3 + repmat(b4,1,num_data));
in1 = a4(:,1:size(a1,1));
in2 = a4(:,size(a1,1)+1:end);
a5 = sigmoid(W5 * in1 + repmat(b(5),1,num_data));
a6 = sigmoid(W6 * in2 + repmat(b(6),1,num_data));

delta{6} = -(data2-a6) .* (a6.*(1-a6));
delta{5} = -(data1-a5) .* (a5.*(1-a5));
delta{4} = ([W5;W6]' * [delta{5};delta{6}] + repmat(sdt(beta,s,a4)',1,num_data) ...
    .* (a4 .* (1-a4)));
delta{3} = (W4' * delta{4} + repmat(sdt(beta,s,a3)',1,num_data) .* (a3 .* (1-a3)));
delta{2} = (W3' * delta{3} + repmat(sdt(beta,s,a2)',1,num_data) .* (a2 .* (1-a2)));
delta{1} = (W1' * delta{2} + repmat(sdt(beta,s,a1)',1,num_data) .* (a1 .* (1-a1)));


W6grad = delta{6}*in2'/num_data + lambda*W6;
W5grad = delta{5}*in1'/num_data + lambda*W5;
W4grad = delta{4}*a3'/num_data + lambda*W4;
W3grad = delta{3}*comb'/num_data + lambda*W3;
W2grad = delta{2}*data2'/num_data + lambda*W2;
W1grad = delta{1}*data1'/num_data+lambda*W1;

b1grad = 
b2grad = 
b3grad =
b4grad = 
b5grad = 
b6grad =

cost = sum(sum((data1-a5) .* (data1-a5))/2/m +...
    sum((data2-a6) .* (data2-a6))/2/m +...
    (lambda/2)*(sum(W1(:).^2)+sum(W2(:).^2)+sum(W3(:).^2)+sum(W4(:).^2+sum(W5(:).^2))+sum(W6(:).^2)) +...
    beta_cost(s,a1,beta)+beta_cost(s,a2,beta)+beta_cost(s,a3,beta)+beta_cost(s,a4,beta)+beta_cost(s,a5,beta)+...
    beta_cost(s,a6,beta));

grad = [rbm1Wgrad(:) ; rbm2Wgrad(:) ; W3grad(:) ; W4grad(:) ; W5grad(:) ; W6grad(:); b1grad(:) ; b2grad(:)];
end


function b = beta_cost(s,a,beta)
    beta*(sum(s*log(s./mean(a)') + (1-s)*log((1-s)./(1-mean(a)'))))
end

function sparseDelta = sdt(beta,s,a)
rhohat = mean(a)'
sparseDelta = beta*(-s./rhohat+(1-s)./(1-rhohat));

end

function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end
