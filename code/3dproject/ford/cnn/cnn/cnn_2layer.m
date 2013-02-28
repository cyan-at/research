function cnn_2layer(category,num_images,optConv,savePath,lambda,overlap,patchSize,T,resize_factor,resize_times)
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
    num_train_images = 100;
    num_val_images = 100;
    num_test_images = 100;
else
    if length(num_images) ~= 3
        error('invalid input arguments');
    end
    num_train_images = num_images(1);
    num_val_images = num_images(2);
    num_test_images = num_images(3);
end
if ~exist('optConv','var')
    optConv = 'J';
end
if ~exist('patchSize','var') || isempty(patchSize)
    patchSize = 3;
end
if ~exist('lambda','var') || isempty(lambda)
%     lambda = [1000000 100000 10000 100 10 1 .01 .001];
    lambda = [10000 1000 100];
end
if ~exist('savePath','var') || isempty(savePath)
    savePath = '/mnt/neocortex/scratch/norrathe/data/cnn_models';
end
if ~exist('overlap','var') || isempty(overlap)
    overlap = .7;
end
if ~exist('T','var') || isempty(T)
    T = 100000;
end
if ~exist('resize_factor','var') || isempty(resize_factor)
    resize_factor = .3;
end
if ~exist('resize_times','var')
    resize_times = 1;
end

% Array of all resizing factors. 
resize_array = zeros(resize_times, 1);
j = 0;
for i = ceil(-resize_times/2) : floor(resize_times/2)
    j = j + 1;
    resize_array(j) = 1.2^(i);
end

num_total_images = num_train_images+num_val_images+num_test_images;

if optConv == 'J'
%    addpath /mnt/neocortex/library/gputest/;
%    init_jacket_auto;
end

numChannels = 16;

if ~exist(savePath, 'dir')
    mkdir(savePath);
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
bndbox = cell(1,num_total_images);
raw_bndbox = cell(1, num_total_images);
bbox_size = [0 0 0];
rand_idx = randperm(num_total_images);

for i=1:num_total_images
    
    [~,name] = fileparts(dataBase(rand_idx(i)).name);
    if strcmp(category, 'INRIA')
        IMAGES{i} = imresize( imread( sprintf('%s/%s.png',root_dir,name) ) ,resize_factor);
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
        
        % Car-side dataset
        num = sscanf(name,'image_%d');
        obj = load(sprintf('%s/annotation_%04d.mat',annot_dir,num));
        bndbox{i} = obj.box_coord;
        bb = [bndbox{i}(:,3) bndbox{i}(:,1) bndbox{i}(:,4) bndbox{i}(:,2)]*resize_factor;
        %bndbox{i} = bb;
        raw_bndbox{i} = bb;
        
    end
    
    % apply HOG if needed
    if use_hog
        init_img = IMAGES{i};
        IMAGES{i} = cnnHOG(init_img, patchSize);
        bb = calcHOGbndbox(init_img, patchSize, bb);
        %bndbox{i} = bb;
    end
    if ~isempty(bb)
        bbox_size = bbox_size + [sum(bb(:,4)-bb(:,2)) sum(bb(:,3)-bb(:,1)) size(bb,1)];
    end
    
        
    gt(i).BB = bb;
    gt(i).det = zeros(size(bb,1),1);
    % Toyota has difficult labels unlike caltech data set
    if strcmp(category,'toyota') == 0
        gt(i).diff = zeros(size(bb,1),1);
    end
end

bbox_size = bbox_size/bbox_size(3);
filter_size = round(bbox_size(1:2));

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

numPos = 0;
train_IMAGES = cell(num_train_images,1);
for i=1:num_train_images
    train_IMAGES{i} = IMAGES{i};
    numPos = numPos+size(gt(i).BB,1);
end


val_IMAGES = cell(num_val_images,1);
for i=num_train_images+1:num_train_images+num_val_images
    val_IMAGES{i-num_train_images} = IMAGES{i};
end

test_IMAGES = cell(num_test_images,1);
for i=num_train_images+num_val_images+1:num_train_images+num_val_images+num_test_images
    test_IMAGES{i-num_train_images-num_val_images} = IMAGES{i};
end

train_gt = gt(1:num_train_images);
val_gt = gt(num_train_images+1:num_train_images+num_val_images);
test_gt = gt(num_train_images+num_val_images+1:num_train_images+num_val_images+num_test_images);

[train_IMAGES, train_gt] = remove_empty_data(train_IMAGES,train_gt,filter_size);
[test_IMAGES, test_gt] = remove_empty_data(test_IMAGES,test_gt,filter_size);
[val_IMAGES, val_gt] = remove_empty_data(val_IMAGES,val_gt,filter_size);
clear IMAGES gt;

%% Train Unsupervised Feature learning - Kmeans Tri
num_hid = numChannels;
maxIter = 300;
pyramid = 1;
patchSize = 4;
savepath = sprintf('/mnt/neocortex/scratch/norrathe/data/centroids/%s_num_hid%d_ps%d,mat',category,num_hid,patchSize);
try
    load(savepath);
catch

    % Extract positive ground truth from training dataset
    unsupIMAGES = cell(numPos,1);
    idx = 1;
    for i=1:num_train_images
        for j=1:size(train_gt(i).BB,1)
            bb = round(train_gt(i).BB(j,:));
            unsupIMAGES{idx} = train_IMAGES{i}(bb(2):bb(4),bb(1):bb(3),:);
            idx = idx+1;
        end
    end
    % Learn k-means tri
    unsupObj = train_unsup(unsupIMAGES, num_hid, maxIter, pyramid, patchSize);
    clear unsupIMAGES
    center = unsupObj.center;
    save(savepath,'center');
end

%% Pre-compute ground truth matrix - Assume patch size = step size

% reduce filter_size to be a multiple of patchSize
filter_size = patchSize*floor(filter_size./patchSize);

[train_Y] = getY(train_IMAGES,train_gt,overlap,num_train_images,filter_size,patchSize);
[val_Y] = getY(val_IMAGES,val_gt,overlap,num_val_images,filter_size,patchSize);
[test_Y] = getY(test_IMAGES,test_gt,overlap,num_test_images,filter_size,patchSize);


%% Compute kmeans-tri features - does not do max pooling yet
train_feat = cell(length(train_IMAGES),1);
for i=1:length(train_IMAGES)
    train_feat{i} = max_pooling(train_IMAGES{i},center,patchSize,filter_size,0);
end
val_feat = cell(length(val_IMAGES),1);
for i=1:length(val_IMAGES)
    val_feat{i} = max_pooling(val_IMAGES{i},center,patchSize,filter_size,0);
end
test_feat = cell(length(test_IMAGES),1);
for i=1:length(test_IMAGES)
    test_feat{i} = max_pooling(test_IMAGES{i},center,patchSize,filter_size,0);
end
filter_size = floor(filter_size/patchSize);

%% Train the filter
% First look up for previously saved models.
% saveName = sprintf('%s_iter%d_use_hog%d_patchSize%d_lambda%g_overlap%g_resize%g', category, T, use_hog, patchSize, lambda, overlap, resize_factor);
% CompleteSavePath = sprintf('%s/%s.mat', savePath, saveName);
% try 
%     load(CompleteSavePath);
% catch
    model = train_2layercnn(train_feat,train_Y,val_feat,val_Y,train_gt,val_gt,overlap,filter_size,numChannels,lambda,T,optConv,patchSize);
%     save(CompleteSavePath, 'model');
% end

%% TEST part
pred_bbox = predict_cnn(train_feat,filter_size,length(train_IMAGES),model,optConv);
for j=1:length(pred_bbox)
    if isempty(pred_bbox{j})
        continue;
    end
    pred_bbox{j}(:,1) = (pred_bbox{j}(:,1)-1)*patchSize+1;
    pred_bbox{j}(:,2) = (pred_bbox{j}(:,2)-1)*patchSize+1;
    pred_bbox{j}(:,3) = pred_bbox{j}(:,1)+patchSize*filter_size(2)-1;
    pred_bbox{j}(:,4) = pred_bbox{j}(:,2)+patchSize*filter_size(1)-1;
end
[acc ap] = eval_cnn(pred_bbox,train_gt,0.5,'ap')

pred_bbox = predict_cnn(test_feat,filter_size,length(test_IMAGES),model,optConv);
for j=1:length(pred_bbox)
    if isempty(pred_bbox{j})
        continue;
    end
    pred_bbox{j}(:,1) = (pred_bbox{j}(:,1)-1)*patchSize+1;
    pred_bbox{j}(:,2) = (pred_bbox{j}(:,2)-1)*patchSize+1;
    pred_bbox{j}(:,3) = pred_bbox{j}(:,1)+patchSize*filter_size(2)-1;
    pred_bbox{j}(:,4) = pred_bbox{j}(:,2)+patchSize*filter_size(1)-1;
end
[acc ap] = eval_cnn(pred_bbox,test_gt,0.5,'ap')

if optConv == 'J'
   clear gpu_hook;
end

% display PC/RC curve
plot(acc.rc,acc.pc,'-');
grid;
xlabel 'recall'
ylabel 'precision'
title(sprintf('class: %s, AP = %.3f',category,ap));

% Visualize higher level features
for j=1:num_hid
    subplot(ceil(sqrt(num_hid)),ceil(sqrt(num_hid)),j);
    imagesc(model.W(:,:,j));
end

    
function [Y gt] = gety(I,gt_bndbox,fSize,o,gs)

[h, w, ~] = size(I);

offsetX = 1;
offsetY = 1;
[r1 c1] = meshgrid(offsetY + fSize(1)/2 : gs : h-fSize(1)/2 + 1,...
    offsetX + fSize(2)/2 : gs : w-fSize(2)/2 + 1);

Y = ones(length(unique(r1)),length(unique(c1)))-2;
s = size(Y);
r1 = r1(:)-fSize(1)/2;
c1 = c1(:)-fSize(2)/2;
r2 = r1+fSize(1)-1;
c2 = c1+fSize(2)-1;
bbox = [c1 r1 c2 r2];

% transform gt_bndbox from pixel level to kmeans feature coordinate
% TODO: figure out whether need ceil and floor or not??
gt(:,1) = ceil((gt_bndbox(:,1)-offsetX+1)./gs);
gt(:,2) = ceil((gt_bndbox(:,2)-offsetY+1)./gs);
gt(:,3) = floor((gt_bndbox(:,3)-offsetX+1)./gs);
gt(:,4) = floor((gt_bndbox(:,4)-offsetY+1)./gs);

for i=1:size(gt_bndbox,1)
    
    idx = (boxoverlap(bbox,gt_bndbox(i,:)) > o);
    b = bbox(idx,:);
    if isempty(b)
        continue;
    end
    Y((b(:,2)-offsetY)/gs+1,(b(:,1)-offsetX)/gs+1) = 1;
end


if size(Y) ~= s
    error('eee');
end


function [Y res_gt] = getY(IMAGES,gt,overlap,num_images,filter_size,gs)

res_gt = gt;
Y = cell(num_images,1);
for i=1:num_images
    [h w ~] = size(IMAGES{i});
    if h < filter_size(1) || w < filter_size(2)
        IMAGES{i} = [];
        Y{i} = [];
        fprintf('Image %d is smaller than filter: (%d,%d) vs (%d,%d)\n',i,h,w,filter_size(1),filter_size(2));
        continue;
    end
    [Y{i} res_gt(i).BB] = gety(IMAGES{i},gt(i).BB,filter_size,overlap,gs);
end

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