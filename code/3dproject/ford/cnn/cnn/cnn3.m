function cnn2
% Running cnn with cnn_gen_grad for gradient. Can change type of gradient
% in train_cnn line 127.

% If change gradient type, need to change the activation in predict_cnn.m
% as well. For now, predict_cnn.m is the same activation as in
% cnn_gen_grad.m

addpath ../detection/
% addpath /mnt/neocortex/scratch/kihyuks/conv2_ipp/
addpath minFunc/
%% Hyper parameters

% lambda is used for l2-reguralization in updating gradient
% T is max iterations in optimization
% numChannels = 3 if RGB, 1 if gray
% optConv: 'J' uses jacket (need to do initial setup first), [] uses CPU
% K: number of folds in Cross Validation
% resize_factor: to resize the images and bbox

% TODO: tune overlap and lambda

num_total_images = 300;
num_train_images = 250;
num_test_images = num_total_images - num_train_images;

T = 10000;
lambda = 20000;
overlap = 0.75;
optConv = '';
if optConv == 'J'
   addpath /mnt/neocortex/library/gputest/;
   init_jacket_auto;
end
numChannels = 3;
resize_factor = 1;
K = [];
if isempty(K) == 0
    eval_opt = 'ap';
else
    eval_opt = [];
    if length(lambda) > 1 | length(overlap) > 1
        error('K is empty');
    end
end
global use_hog;
global patchSize;

use_hog = 1;
patchSize = 10;
visualize_pred = 1;
if use_hog
    numChannels = 32;
end

savePath = '/home/linshu/3d_car/cnn/models';
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

%% Prepare data
root_dir = '/mnt/neocortex/data/101_ObjectCategories/Faces';
annot_dir = '/mnt/neocortex/data/101_ObjectCategories_tightbb/Annotations/Faces';
category = 'faces';
% root_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/pos';
% annot_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/annotations';
dataBase = dir(root_dir);
dataBase = dataBase(3:end);

IMAGES = cell(1,num_total_images);
init_images = cell(1,num_total_images);
bndbox = cell(1,num_total_images);
bbox_size = [0 0 0];
for i=1:num_total_images
    [~,name] = fileparts(dataBase(i).name);
    IMAGES{i} = im2double( imresize( imread( sprintf('%s/%s.jpg',root_dir,name) ) ,resize_factor));
    
    % Car-side dataset
    num = sscanf(name,'image_%d');
    obj = load(sprintf('%s/annotation_%04d.mat',annot_dir,num));
    bndbox{i} = obj.box_coord;
    bb = [bndbox{i}(:,3) bndbox{i}(:,1) bndbox{i}(:,4) bndbox{i}(:,2)]*resize_factor;
    bndbox{i} = bb;

    if use_hog
        init_img = IMAGES{i};
        IMAGES{i} = cnnHOG(init_img, patchSize);
        bb = calcHOGbndbox(init_img, patchSize, bb);
        bndbox{i} = bb;
    end
    bbox_size = bbox_size + [sum(bb(:,4)-bb(:,2)) sum(bb(:,3)-bb(:,1)) size(bb,1)];
    
    % INRIA dataset
%     t = textread(sprintf('%s/%s.txt',annot_dir,name),'%s');
%     bbox_idx = find(strcmp(t,'(Xmin,')==1);
%     bndbox{i} = zeros(length(bbox_idx),4);
%     for j=1:length(bbox_idx)
%         bndbox{i}(j,:) = [sscanf(t{bbox_idx(j)+6},'(%d,') sscanf(t{bbox_idx(j)+7},'%d)') sscanf(t{bbox_idx(j)+9},'(%d,') sscanf(t{bbox_idx(j)+10},'%d)')];
%     end
%     bb = bndbox{i};
        
    gt(i).BB = bb;
    gt(i).det = zeros(size(bb,1),1);
    gt(i).diff = zeros(size(bb,1),1);
end

% randomize the order of images.
rand_ind = randperm(num_total_images);
IMAGES = IMAGES(rand_ind);
gt = gt(rand_ind);

bbox_size = bbox_size/bbox_size(3);
filter_size = round(bbox_size(1:2));

% Remove images where the filter does not fit.
Y = cell(num_total_images,1);
for i=1:num_total_images
    [h w ~] = size(IMAGES{i});
    if h < filter_size(1) || w < filter_size(2)
        IMAGES{i} = [];
        Y{i} = [];
        fprintf('Image %d is smaller than filter: (%d,%d) vs (%d,%d)\n',i,h,w,filter_size(1),filter_size(2));
        continue;
    end
    Y{i} = gety(IMAGES{i},gt(i).BB,filter_size,overlap);
end

%init_total_train = num_train_images;

is_empty = cellfun('isempty', IMAGES);
IMAGES = IMAGES(~is_empty);
[~, id] = find(is_empty > 0);

% Correct the number of total images.
num_total_images = num_total_images - sum(is_empty);

% Correct the number of training images.
ls_train_num = (id <= num_train_images);
num_train_images = num_train_images - sum(ls_train_num);

% Correct the number of testing iamges.
% gt_train_num = (id > num_train_images);
% num_test_images = num_test_images - gt_train_num;

is_empty = cellfun('isempty', Y);
Y = Y(~is_empty);
gt = gt(~is_empty);

%% Checking gradient

% mult = .1;
% fsize = round(filter_size*mult);
% for i=1:5
%     I{i} = IMAGES{i};
%     Y{i} = gety(I{i},gt(i).BB, filter_size, overlap);
% end
% w = 2*rand([filter_size numChannels])-1;
% b = 2*rand(1)-1;
% t = [w(:); b];
% 
% [cost2, grad2] = cnn_gen_grad(I,Y,t,filter_size,numChannels,[],lambda);
% numgrad2 = computeNumericalGradient(@(x) cnn_gen_grad(I,Y,x,filter_size,numChannels,[],lambda),t);
% diff2 = norm(numgrad2-grad2)/norm(numgrad2+grad2)

%% Train the filter

% First look up for previously saved models.
saveName = sprintf('%s_iter%d_use_hog%d_patchSize%d_lambda%g_overlap%g', category, T, use_hog, patchSize, lambda, overlap);
CompleteSavePath = sprintf('%s/%s.mat', savePath, saveName);

try 
    load(CompleteSavePath);
catch
    model = train_cnn(IMAGES,overlap,num_train_images,filter_size,gt,numChannels,lambda,T,optConv,K,eval_opt);
    save(CompleteSavePath, 'model');
end

%% TEST part - to do
train_IMAGES = cell(num_train_images,1);
for i=1:num_train_images
    train_IMAGES{i} = IMAGES{i};
end
pred_bbox = predict_cnn(train_IMAGES,filter_size,length(train_IMAGES),model,optConv);
[acc ap] = eval_cnn(pred_bbox,gt(1:num_train_images),0.5,'ap')

test_IMAGES = cell(num_total_images-num_train_images,1);

for i=num_train_images+1:length(IMAGES)
    test_IMAGES{i-num_train_images} = IMAGES{i};
end
pred_bbox = predict_cnn(test_IMAGES,filter_size,length(test_IMAGES),model,optConv);
[acc ap] = eval_cnn(pred_bbox,gt(num_train_images+1:end),0.5,'ap')

% Visualize some predictions for HOG.
if visualize_pred
    for j = 1 : 10
        bounded = test_IMAGES{j};
        if isempty(bounded)
            continue;
        end
        
        if isempty(pred_bbox{j})
            continue;
        end
        visual_bbox = round(pred_bbox{j}(1:4));
        
        if visual_bbox(4) > size(bounded, 1)
            visual_bbox(4) = size(bounded, 1);
        end
        if visual_bbox(3) > size(bounded, 2)
            visual_bbox(3) = size(bounded, 2);
        end
        %offset = j + num_train_images
        %fprintf('Original image num: %d\n', num_train_images + sum(ls_train_num) + )
        bounded = bounded(visual_bbox(2):visual_bbox(4), visual_bbox(1):visual_bbox(3), :);
        if (~isempty(bounded))
            visualizeHOG(bounded);
        end
        pause;
    end
end
plot(acc.rc,acc.pc,'-');
grid;
xlabel 'recall'
ylabel 'precision'
title(sprintf('class: faces, AP = %.3f',ap));


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

