function model = train_cnn(train_IMAGES,val_IMAGES,train_gt,val_gt,overlap,filter_size,numChannels,lambda,numIter,optConv,resize_array)

% will train cnn on IMAGES{1:num_images} with assume their ground truth
% bbox store in gt(1:num_images).BB. K-fold CV if needed
% mode.W's size = [filter_size numChannels]

if nargin == 6
    optConv = [];
    numIter = 10000;
end

if length(lambda) > 1
    val_cost = cell(length(lambda),1);
    val_cost_l = cell(length(lambda),1);
    train_cost = cell(length(lambda),1);
    train_cost_l = cell(length(lambda),1);
    val_acc = cell(length(lambda),1);
%     train_acc = cell(length(lambda),1);
    val_ap = cell(length(lambda),1);
    models = cell(length(lambda),1);
    
    
%         if exist('resize_array','var') && ~isempty(resize_array) && length(resize_array) > 1
%             pred_bbox = predict_cnn2(val_IMAGES,filter_size,length(val_IMAGES),models{i},optConv, length(resize_array), resize_array);
%         else
%             pred_bbox = predict_cnn(val_IMAGES,filter_size,length(val_IMAGES),models{i},optConv);
%         end
    parfor i=1:length(lambda)
        Y = getY(train_IMAGES,train_gt,overlap,length(train_IMAGES),filter_size);
        models{i} = sub_train_cnn(train_IMAGES,Y,length(train_IMAGES),filter_size,numChannels,lambda(i),numIter,optConv);
        
        Y = getY(val_IMAGES,val_gt,overlap,length(val_IMAGES),filter_size);
        val_cost{i} = batch_obj_func(val_IMAGES,Y,models{i}.W,models{i}.b,numChannels,optConv,[]);
        val_cost_l{i} = batch_obj_func(val_IMAGES,Y,models{i}.W,models{i}.b,numChannels,optConv,lambda(i));
        pred_bbox = predict_cnn2(val_IMAGES,filter_size,length(val_IMAGES),models{i},optConv, length(resize_array), resize_array);
        [val_acc{i}, val_ap{i}] = eval_cnn(pred_bbox,val_gt,0.5,'ap');
    end
    [~, idx] = max(cat(1,val_ap{:}));
    model = models{idx};
else
    Y = getY(train_IMAGES,train_gt,overlap,length(train_IMAGES),filter_size);
    model = sub_train_cnn(train_IMAGES,Y,length(train_IMAGES),filter_size,numChannels,lambda,numIter,optConv);
end

function Y = getY(IMAGES,gt,overlap,num_images,filter_size)

Y = cell(num_images,1);
for i=1:num_images
    [h w ~] = size(IMAGES{i});
    if h < filter_size(1) || w < filter_size(2)
        IMAGES{i} = [];
        Y{i} = [];
        fprintf('Image %d is smaller than filter: (%d,%d) vs (%d,%d)\n',i,h,w,filter_size(1),filter_size(2));
        continue;
    end
    Y{i} = gety(IMAGES{i},gt(i).BB,filter_size,overlap);
end


function [model cost] = sub_train_cnn(IMAGES,Y,num_images,filter_size,numChannels,lambda,numIter,optConv)
addpath(genpath('/mnt/neocortex/scratch/norrathe/minFunc_2012/'))

%% Train the model, save models every 200 iterations
% load('/mnt/neocortex/scratch/norrathe/data/cnn_models/mean_gt.mat');
% W = w;
W = 2*rand([filter_size size(IMAGES{1},3)])-1;
b = 2*rand(1)-1;

model.oW = W;
model.oB = b;

maxIter = numIter;

addpath(genpath('/mnt/neocortex/scratch/norrathe/minFunc_2012/'))
options.Method = 'lbfgs';
options.maxIter = maxIter;
options.progTol = 1e-5;
options.display = 'on';
options.MaxFunEvals = maxIter;

theta = [W(:) ; b];

tic
[opttheta cost] = minFunc( @(p) cnn_gen_grad(IMAGES,Y,p,filter_size,numChannels,optConv,lambda,1), theta,options);
toc

model.W = reshape(opttheta(1:end-1),size(W,1),size(W,2),numChannels);
model.b = opttheta(end);

function Y = gety(I,gt_bndbox,fSize,o)
Y = ones(size(I(:,:,1))-fSize+1)-2;
s = size(Y);
[r1 c1] = meshgrid(1:size(Y,1), 1:size(Y,2));
r1 = r1(:);
c1 = c1(:);
r2 = r1+fSize(1)-1;
c2 = c1+fSize(2)-1;
bbox = [c1 r1 c2 r2];

for i=1:size(gt_bndbox,1)
    idx = (boxoverlap(bbox,gt_bndbox(i,:)) > o);
    b = bbox(idx,:);
    if isempty(b)
        continue;
    end
    Y(b(:,2),b(:,1)) = 1;
end


if size(Y) ~= s
    error('eee');
end

function l = learning_rate(t)
l = .001/(1+t/10);
% .001/(1+t/100) works for resize_factor = .5
% .00001/(1+t/100)