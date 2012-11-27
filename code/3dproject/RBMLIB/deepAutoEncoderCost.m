function [ cost, grad ] = deepAutoEncoderCost(theta, l, data1, data2,...
    beta,...
    lambda,...
    s...
)

%% Unroll parameters
sidx = 0;
for i=1:size(l,1);
    tmp{i} = reshape(theta(sidx+1:sidx+l(i,1)*l(i,2)),l(i,1),l(i,2));
    sidx = sidx+l(i,1)*l(i,2);
end
W1 = tmp{1};
W2 = tmp{2};
W3 = tmp{3};
W4 = tmp{4};
W5 = tmp{5};
W6 = tmp{6};
b1 = tmp{7};
b2 = tmp{8};
b3 = tmp{9};
b4 = tmp{10};
b5 = tmp{11};
b6 = tmp{12};
clear tmp;

%W1 is rbm1.W'
%W2 is rbm2.W'
%W3 is rbmSecond.W'
%W4 is rbmSecond.W
%W5 is rbm1.W
%W6 is rbm2.W

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
%feedforward
num_data = num_data1;
a1 = sigmoid(W1 * data1 + repmat(b1,1,num_data));
a2 = sigmoid(W2 * data2 + repmat(b2,1,num_data));
comb = [a1;a2];
a3 = sigmoid(W3 * comb + repmat(b3,1,num_data));
% clear comb
a4 = sigmoid(W4 * a3 + repmat(b4,1,num_data));
in1 = a4(1:size(a1,1),:);
in2 = a4(size(a1,1)+1:end,:);
% clear a4
a5 = sigmoid(W5 * in1 + repmat(b5,1,num_data));
a6 = sigmoid(W6 * in2 + repmat(b6,1,num_data));

delta{6} = -(data2-a6) .* (a6.*(1-a6));
delta{5} = -(data1-a5) .* (a5.*(1-a5));
in1Delta = ([W5;W6]' * [delta{5};delta{6}] + repmat(sdt(beta,s,in1),1,num_data)) .* (in1 .* (1-in1));
in2Delta = ([W5;W6]' * [delta{5};delta{6}] + repmat(sdt(beta,s,in2),1,num_data)) .* (in2 .* (1-in2));
delta{4} = [in1Delta;in2Delta];

delta{3} = (W4' * delta{4} + repmat(sdt(beta,s,a3),1,num_data) .* (a3 .* (1-a3)));
delta3 = W3'*delta{3}; 
delta2 = delta3(1:size(a2,1),:);
delta1 = delta3(size(a2,1)+1:end,:);
delta{2} = (delta2 + repmat(sdt(beta,s,a2),1,num_data) .* (a2 .* (1-a2)));
delta{1} = (delta1 + repmat(sdt(beta,s,a1),1,num_data) .* (a1 .* (1-a1)));


W6grad = delta{6}*in2'/num_data + lambda*W6;
b6grad = sum(delta{6},2)/num_data;
W5grad = delta{5}*in1'/num_data + lambda*W5;
b5grad = sum(delta{5},2)/num_data;
W4grad = delta{4}*a3'/num_data + lambda*W4;
b4grad = sum(delta{4},2)/num_data;

W3grad = delta{3}*comb'/num_data + lambda*W3;
b3grad = sum(delta{3},2)/num_data;
W2grad = delta{2}*data2'/num_data + lambda*W2;
b2grad = sum(delta{2},2)/num_data;
W1grad = delta{1}*data1'/num_data+lambda*W1;
b1grad = sum(delta{1},2)/num_data;

cost = sum(sum((data1-a5) .* (data1-a5))/(2*num_data) +...
    sum((data2-a6) .* (data2-a6))/(2*num_data) +...
    (lambda/2)*(sum(W1(:).^2)+sum(W2(:).^2)+sum(W3(:).^2)+sum(W4(:).^2+sum(W5(:).^2))+sum(W6(:).^2)) +...
    beta_cost(s,a1,beta)+beta_cost(s,a2,beta)+beta_cost(s,a3,beta)+beta_cost(s,a4,beta)+beta_cost(s,a5,beta)+...
    beta_cost(s,a6,beta));

    grad = [W1grad(:) ; W2grad(:) ; W3grad(:) ; W4grad(:) ; W5grad(:) ; W6grad(:); ...
            b1grad(:) ; b2grad(:) ; b3grad(:) ; b4grad(:) ; b5grad(:) ; b6grad(:)];
end


function b = beta_cost(s,a,beta)
    b = beta*(sum(s*log(s./mean(a)') + (1-s)*log((1-s)./(1-mean(a)'))));
end

function sparseDelta = sdt(beta,s,a)
    rhohat = mean(a,2);
    sparseDelta = beta*(-s./rhohat+(1-s)./(1-rhohat));
end

function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
end

