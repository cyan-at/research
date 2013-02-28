function cnn2(category,method,num_images,optConv,savePath,lambda,overlap,patchSize,T,resize_factor,resize_times)
%% PARAMETERS:
% category: so far available for 'airplanes', 'faces'
% lambda: for regularization. If length(lambda) > 1, it will select the best one based on val ap
% overlap: overlap ratio in training detector (default .8)
% T: max iterations in optimization (default 100k)
% optConv: 'J' (default) uses jacket, [] uses CPU
% resize_factor: to resize the images and bbox before using (default .3)

%% EXAMPLE: 
% cnn2('faces','hog',[200 50 50],'J','/mnt/neocortex/scratch/norrathe/tmp/',[1000, 10, 1],.8,10,100000,1);
% cnn2('faces','pixels',[],'J',[],100,[]);
% cnn2(run with default setup)
% cnn2('faces','hog') -> 
% cnn2('faces','pixels') -> should get 0.9082 for test ap and 0.9091 for training

%% NOTE:
% If change gradient type, need to change the activation in predict_cnn.m
% as well. For now, predict_cnn.m is the same activation as in
% cnn_gen_grad.m

%% List of hyper parameters
% lambda
% overlap
% patchSize (for HOG)

if ~exist('category','var') || isempty(category)
    category = 'faces';
end
if ~exist('num_images','var') || isempty(num_images)
    num_train_images = 200;
    num_val_images = 50;
    num_test_images = 50;
else
    if length(num_images) ~= 3
        error('invalid input arguments');
    end
    num_train_images = num_images(1);
    num_val_images = num_images(2);
    num_test_images = num_images(3);
end
if ~exist('optConv','var')
    optConv = '';
end
if ~exist('method','var') || isempty(method)
    method = 'hog';
end
if ~exist('patchSize','var') || isempty(patchSize)
    patchSize = 10;
end
if ~exist('lambda','var') || isempty(lambda)
    lambda = 50000;
end
if ~exist('savePath','var') || isempty(savePath)
    savePath = '/mnt/neocortex/scratch/norrathe/data/cnn_models';
end
if ~exist('overlap','var') || isempty(overlap)
    overlap = .70;
end
if ~exist('T','var') || isempty(T)
    T = 100000;
end
if ~exist('resize_factor','var') || isempty(resize_factor)
    resize_factor = 7;
end

num_total_images = num_train_images+num_val_images+num_test_images;

if ~exist('resize_times','var') || isempty(resize_times)
    resize_times = 3;
end

if optConv == 'J'
   addpath /mnt/neocortex/library/gputest/;
   init_jacket_auto;
end

if strcmp(method,'hog')
    use_hog = 1;
else
    use_hog = 0;
end

if use_hog
    numChannels = 32;
else
    numChannels = 3;
end

if ~exist(savePath, 'dir')
    mkdir(savePath);
end

num_train_images = 50;
num_val_images = 20;
num_test_images = 30;

num_total_images = num_train_images + num_val_images + num_test_images;

T = 10000;
lambda = [50000, 1000, 500, 10];
overlap = 0.80;
optConv = 'J';
use_hog = 0;
numChannels = 3;
patchSize = 6;
resize_factor = .1;
resize_times = 7;
category = 'toyota';
resize_base = 1.2;

% Array of all resizing factors. 
resize_array = zeros(resize_times, 1);
j = 0;
for i = ceil(-resize_times/2) : floor(resize_times/2)
    j = j + 1;
    resize_array(j) = resize_base^(i);
end

addpath ../detection/
addpath /mnt/neocortex/scratch/kihyuks/conv2_ipp/
s = RandStream('mcg16807','Seed',0);
RandStream.setGlobalStream(s);

%% Prepare data - get IMAGES, groundtruth gt (BB, det, diff) and filter_size

switch category
    case 'airplanes'
        root_dir = '/mnt/neocortex/data/101_ObjectCategories/airplanes';
        annot_dir = '/mnt/neocortex/data/101_ObjectCategories_tightbb/Annotations/airplanes';
    case 'faces'
        root_dir = '/mnt/neocortex/data/101_ObjectCategories/Faces';
        annot_dir = '/mnt/neocortex/data/101_ObjectCategories_tightbb/Annotations/Faces';
    case 'INRIA'
        root_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/pos';
        annot_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/annotations';
    case 'toyota'
        root_dir = '/mnt/neocortex/scratch/3dproject/Toyota_scene/data/mat';
end
dataBase = dir(root_dir);
dataBase = dataBase(3:end);

IMAGES = cell(1,num_total_images);
raw_IMAGES = cell(1, num_total_images);
bndbox = cell(1,num_total_images);
raw_bndbox = cell(1, num_total_images);
bbox_size = [0 0 0];
rand_idx = randperm(num_total_images);

for i=1:num_total_images
    
    [~,name] = fileparts(dataBase(rand_idx(i)).name);
    if strcmp(category, 'INRIA')
        IMAGES{i} = ( imresize( (imread( sprintf('%s/%s.png',root_dir,name) ) ),resize_factor));
        raw_IMAGES{i} = IMAGES{i};
        % INRIA dataset
        t = textread(sprintf('%s/%s.txt',annot_dir,name),'%s');
        bbox_idx = find(strcmp(t,'(Xmin,')==1);
        bndbox{i} = zeros(length(bbox_idx),4);
        for j=1:length(bbox_idx)
            bndbox{i}(j,:) = [sscanf(t{bbox_idx(j)+6},'(%d,') sscanf(t{bbox_idx(j)+7},'%d)') sscanf(t{bbox_idx(j)+9},'(%d,') sscanf(t{bbox_idx(j)+10},'%d)')];
        end
        bb = bndbox{i};
        raw_bndbox{i} = bb;
    elseif strcmp(category, 'toyota')
        load(sprintf('%s/%s.mat',root_dir,name));
        img = imresize(img, resize_factor);
        IMAGES{i} = img;
        raw_IMAGES{i} = IMAGES{i};
        bb = [];
        diff = [];
        for j=1:length(obj)
%             if isempty(obj(j).truncated) == 0 && obj(j).truncated == 1
%                 continue;
%             end
            bbox = obj(j).bndbox*resize_factor;
            if bbox(4)-bbox(2) < 50*resize_factor || bbox(3)-bbox(1) < 50*resize_factor
                continue;
            end
            bb = [bb; bbox];
            if isempty(obj(j).difficult) || obj(j).difficult == 0
                diff = [diff; 0];
            else
                diff = [diff; 1];
            end
        end
        raw_bndbox{i} = bb;
        gt(i).diff = diff;
    else
        IMAGES{i} = ( imresize( (imread( sprintf('%s/%s.jpg',root_dir,name) ) ),resize_factor));
        raw_IMAGES{i} = IMAGES{i};
        
        % Car-side dataset
        num = sscanf(name,'image_%d');
        obj = load(sprintf('%s/annotation_%04d.mat',annot_dir,num));
        bndbox{i} = obj.box_coord;
        bb = [bndbox{i}(:,3) bndbox{i}(:,1) bndbox{i}(:,4) bndbox{i}(:,2)]*resize_factor;
        %bndbox{i} = bb;
        raw_bndbox{i} = bb;
        
     end
    if use_hog
        init_img = IMAGES{i};
        IMAGES{i} = cnnHOG(init_img, patchSize);
        bb = calcHOGbndbox(init_img, patchSize, bb);
        %bndbox{i} = bb;
    end
    if isempty(bb) == 0
        bbox_size = bbox_size + [sum(bb(:,4)-bb(:,2)) sum(bb(:,3)-bb(:,1)) size(bb,1)];
    end
    
        
    gt(i).BB = bb;
    gt(i).det = zeros(size(bb,1),1);
    if strcmp(category,'toyota') == 0
        gt(i).diff = zeros(size(bb,1),1);
    end
end

bbox_size = bbox_size/bbox_size(3);
filter_size = round(bbox_size(1:2));

% randomize the order of images.
% rand_ind = randperm(num_total_images);
% IMAGES = IMAGES(rand_ind);
% gt = gt(rand_ind);

% if resize_times > 1
%     % After getting the images, resize them to different scales.
%     new_images = cell(1, num_total_images * resize_times);
%     new_bnd = cell(1, num_total_images * resize_times);
%     
%     
%     for i = 1 : resize_times
%         for j = 1 : num_total_images
%             
%             % Resize every image and bndboxes.
%             new_images{(i - 1) * num_total_images + j} = imresize(IMAGES{j}, resize_array(i));
%             bb = bndbox{j} * resize_array(i);
%             new_bnd{(i - 1) * num_total_images + j} = bb;
%             gt((i - 1) * num_total_images + j).BB = bb;
%             gt((i - 1) * num_total_images + j).det = zeros(size(bb,1),1);
%             gt((i - 1) * num_total_images + j).diff = zeros(size(bb,1),1);
%             
%         end
%     end
%     
%     num_total_images = num_total_images * resize_times;
%     IMAGES = new_images;
% end

%% Checking gradient

% mult = 1;
% fsize = round(filter_size*mult);
% for i=1:10
%     I{i} = imresize(IMAGES{i},mult);
%     Y{i} = gety(I{i},gt(i).BB*mult,fsize,0.8);
% end
% numHidden = 1;
% w1 = 2*rand([fsize numHidden])-1;
% w2 = 2*rand(numHidden,1)-1;
% b = 2*rand(2,1)-1;
% t = [w1(:); w2(:); b(:)];
% [cost grad] = cnn_2layer_grad(I,Y,t,numHidden,fsize,0);
% % numgrad = computeNumericalGradient(@(x) cnn_2layer_grad(I,Y,x,numHidden,fsize,0),t);
% % diff = norm(numgrad-grad)/norm(numgrad+grad)

%% Spit data (train, test, val)

% num_train_images = num_train_images * resize_times;
% num_val_images = num_val_images * resize_times;
% num_test_images = num_test_images * resize_times;

train_gt = gt(1:num_train_images);
val_gt = gt(num_train_images+1:num_train_images+num_val_images);
test_gt = gt(num_train_images+num_val_images+1:num_train_images+num_val_images+num_test_images);

train_IMAGES = cell(num_train_images,1);
for i=1:num_train_images
    train_IMAGES{i} = IMAGES{i};
end

% if resize_times > 1
    % After getting the images, resize them to different scales.
    new_train_images = cell(1, num_train_images * resize_times);
    %new_bnd = cell(1, num_total_images * resize_times);
    
    for i = 1 : resize_times
        for j = 1 : num_train_images
            
            % Resize every image and bndboxes.
            new_train_images{(i - 1) * num_train_images + j} = im2double(imresize(raw_IMAGES{j}, resize_array(i)));
            bb = raw_bndbox{j} * resize_array(i);
            if use_hog
                init_img = new_train_images{(i - 1) * num_train_images + j};
                
                new_train_images{(i - 1) * num_train_images + j} = cnnHOG(init_img, patchSize);
                bb = calcHOGbndbox(init_img, patchSize, bb);
                %bndbox{i} = bb;
            end
            %new_bnd{(i - 1) * num_train_images + j} = bb;
            new_train_gt((i - 1) * num_train_images + j).BB = bb;
            new_train_gt((i - 1) * num_train_images + j).det = zeros(size(bb,1),1);
            new_train_gt((i - 1) * num_train_images + j).diff = zeros(size(bb,1),1);
            
        end
    end
    
    new_num_train_images = num_train_images * resize_times;
    %train_IMAGES = new_train_images;
% else
%     new_train_images = train_IMAGES;
%     new_train_gt = train_gt;
%     new_num_train_images = num_train_images;
% end


val_IMAGES = cell(num_val_images,1);
for i=num_train_images+1:num_train_images+num_val_images
    val_IMAGES{i-num_train_images} = IMAGES{i};
end

test_IMAGES = cell(num_test_images,1);
for i=num_train_images+num_val_images+1:num_train_images+num_val_images+num_test_images
    test_IMAGES{i-num_train_images-num_val_images} = IMAGES{i};
end

[new_train_images, new_train_gt] = remove_empty_data(new_train_images,new_train_gt,filter_size);
fprintf('Original data:\n');
[train_IMAGES, train_gt] = remove_empty_data(train_IMAGES,train_gt,filter_size);
[test_IMAGES, test_gt] = remove_empty_data(test_IMAGES,test_gt,filter_size);
[val_IMAGES, val_gt] = remove_empty_data(val_IMAGES,val_gt,filter_size);

%% Train the filter

% First look up for previously saved models.
saveName = sprintf('%s/iter%d_use_hog%d_patchSize%d_overlap%g_resizeTimes%d_resizeFactor%g_resizeBase%d', category, T, use_hog, patchSize, overlap, resize_times, resize_factor,resize_base);
CompleteSavePath = sprintf('%s/%s.mat', savePath, saveName);
try 
    load(CompleteSavePath);
catch
    model = train_cnn(new_train_images,val_IMAGES,new_train_gt,val_gt,overlap,filter_size,numChannels,lambda,T,optConv,resize_array);
    save(CompleteSavePath, 'model');
end

%% TEST part



pred_bbox = predict_cnn2(train_IMAGES,filter_size,length(train_IMAGES),model,optConv, resize_times, resize_array);
[acc ap] = eval_cnn(pred_bbox,train_gt,0.5,'ap')

pred_bbox = predict_cnn2(val_IMAGES,filter_size,length(val_IMAGES),model,optConv, resize_times, resize_array);
[acc ap] = eval_cnn(pred_bbox,val_gt,0.5,'ap')

pred_bbox = predict_cnn2(test_IMAGES,filter_size,length(test_IMAGES),model,optConv, resize_times, resize_array);
[acc ap] = eval_cnn(pred_bbox,test_gt,0.5,'ap')

saveName = sprintf('%s/pc_rc_iter%d_use_hog%d_patchSize%d_overlap%g_resizeTimes%d_resizeFactor%g_resizeBase%d', category, T, use_hog, patchSize, overlap, resize_times, resize_factor, resize_base);
CompleteSavePath = sprintf('%s/%s.mat', savePath, saveName);
save(CompleteSavePath, 'acc','ap');
% if optConv == 'J'
%    clear gpu_hook;
% end

plot(acc.rc,acc.pc,'-');
grid;
xlabel 'recall'
ylabel 'precision'
title(sprintf('class: %s, AP = %.3f',category,ap));

function [rI, rgt] = remove_empty_data(I,gt,filter_size)
% Remove empty entries in I and gt, corresponding to that I
if length(I) ~= length(gt)
    error('inconsistent number of elements in I and gt');
end

rI = I;
rgt = gt;
for i=1:length(rI)
    [h w ~] = size(rI{i});
    if h < filter_size(1) || w < filter_size(2)
        rI{i} = [];
        fprintf('Image %d is smaller than filter: (%d,%d) vs (%d,%d)\n',i,h,w,filter_size(1),filter_size(2));
    end
end
is_empty = cellfun('isempty', rI);
rI = rI(~is_empty);
rgt = rgt(~is_empty);