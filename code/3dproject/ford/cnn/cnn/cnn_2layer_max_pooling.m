function cnn_2layer_max_pooling(category,num_images,optConv,savePath,lambda,overlap,patchSize,T,resize_factor)
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
    category = 'toyota';
end
if ~exist('num_images','var') || isempty(num_images)
    num_train_images = 50;
    num_val_images = 20;
    num_test_images = 39;
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
    patchSize = 6;
end
if ~exist('lambda','var') || isempty(lambda)
    lambda = [1000000 100000 10000 100 10 1 .01 .001];
%     lambda = [100000, 50000, 1000, 500];
end
if ~exist('savePath','var') || isempty(savePath)
    savePath = '/mnt/neocortex/scratch/norrathe/data/cnn_models';
end
if ~exist('overlap','var') || isempty(overlap)
    overlap = .8;
end
if ~exist('T','var') || isempty(T)
    T = 100000;
end
if ~exist('resize_factor','var') || isempty(resize_factor)
    resize_factor = .2;
end
if ~exist('resize_times','var')
    resize_times = 5;
end

% Array of all resizing factors. 
resize_array = zeros(resize_times, 1);
j = 0;
for i = ceil(-resize_times/2) : floor(resize_times/2)
    j = j + 1;
    resize_array(j) = 1.2^(i);
end


num_total_images = num_train_images+num_val_images+num_test_images;

% if optConv == 'J'
%    addpath /mnt/neocortex/library/gputest/;
%    init_jacket_auto;
% end

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
    elseif strcmp(category, 'toyota')
        load(sprintf('%s/%s.mat',root_dir,name));
        img = imresize(img, resize_factor);
        IMAGES{i} = img;
        bb = [];
        diff = [];
        for j=1:length(obj)
            if isempty(obj(j).truncated) == 0 && obj(j).truncated == 1
                continue;
            end
            bbox = obj(j).bndbox*resize_factor;
            bbox(1) = max(bbox(1),1);
            bbox(2) = max(bbox(2),1);
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
        gt(i).diff = diff;
    else
        IMAGES{i} = ( imresize( (imread( sprintf('%s/%s.jpg',root_dir,name) ) ),resize_factor));
        
        % Car-side dataset
        num = sscanf(name,'image_%d');
        obj = load(sprintf('%s/annotation_%04d.mat',annot_dir,num));
        bndbox{i} = obj.box_coord;
        bb = [bndbox{i}(:,3) bndbox{i}(:,1) bndbox{i}(:,4) bndbox{i}(:,2)]*resize_factor;
        
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
patchSize = 6;
num_hid = numChannels;
maxIter = 300;
pyramid = 1;
savepath = sprintf('/mnt/neocortex/scratch/norrathe/data/centroids/%s_num_hid%d_resizeFactor%d_ps%d,mat',category,num_hid,resize_factor,patchSize);
% try
%     load(savepath);
% catch

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
    unsupObj = train_unsup(train_IMAGES, num_hid, maxIter, pyramid, patchSize);
%     clear unsupIMAGES
    center = unsupObj.center;
    save(savepath,'center');
% end


%% Pre-compute ground truth matrix - Assume patch size = step size
stepSize = 4;
pool = 1;
% For simplicity, assume filter_size can be wholly partitioned based on 
% pool, patchSize and stepSize
filter_size = (floor( (floor( (filter_size-patchSize)/stepSize)+1)/pool)*pool-1)*stepSize+patchSize;

[train_Y ] = getY(train_IMAGES,train_gt,overlap,num_train_images,filter_size,stepSize*pool);
[val_Y ] = getY(val_IMAGES,val_gt,overlap,num_val_images,filter_size,stepSize*pool);
[test_Y ] = getY(test_IMAGES,test_gt,overlap,num_test_images,filter_size,stepSize*pool);
% train_Y = [];
% val_Y = [];


%% Compute kmeans-tri features - does not do max pooling yet
train_feat = cell(length(train_IMAGES),1);
for i=1:length(train_IMAGES)
    train_feat{i} = max_pooling(train_IMAGES{i},center,patchSize,stepSize,optConv,pool);
end

val_feat = cell(length(val_IMAGES),1);
parfor i=1:length(val_IMAGES)
    val_feat{i} = max_pooling(val_IMAGES{i},center,patchSize,stepSize,optConv,pool);
end
test_feat = cell(length(test_IMAGES),1);
parfor i=1:length(test_IMAGES)
    test_feat{i} = max_pooling(test_IMAGES{i},center,patchSize,stepSize,optConv,pool);
end

%% Amplify training images and compute their features
amp_train_IMAGES = cell(length(train_IMAGES)*resize_times,1);

amp_train_feat = cell(length(train_IMAGES)*resize_times,1);
if resize_times == 1
    amp_train_IMAGES = train_IMAGES;
    amp_train_gt = train_gt;
    amp_train_feat = train_feat;
else
    for i=1:length(train_IMAGES)
        img = train_IMAGES{i};
        for j=1:resize_times
            resized_img = imresize(img,resize_array(j));
            idx = (i-1)*resize_times+j;
            amp_train_IMAGES{idx} = resized_img;
            amp_train_gt(idx) = train_gt(i);
            amp_train_gt(idx).BB = amp_train_gt(idx).BB*resize_array(j);
            amp_train_feat{idx} = max_pooling(resized_img,center,patchSize,stepSize,optConv,pool);
        end 
    end
end
[amp_train_Y ] = getY(amp_train_IMAGES,amp_train_gt,overlap,num_train_images*resize_times,filter_size,stepSize*pool);

% update the filter size
filter_size = ((filter_size-patchSize)/stepSize+1)/pool;
%% GRADIENT
% W = 2*rand([filter_size size(train_feat{1},3)])-1;
% b = 2*rand(1)-1;
% theta = [W(:) ; b];
% I{1} = train_feat{3};
% I{2} = train_feat{2};
% YI{1} = train_Y{3};
% YI{2} = train_Y{2};
% [opttheta grad] = cnn_gen_grad(I,YI,theta,filter_size,numChannels,optConv,1,1);
% numgrad = computeNumericalGradient(@(x) cnn_gen_grad(I,YI,x,filter_size,numChannels,optConv,1,1),theta);
% diff = norm(numgrad-grad)/norm(numgrad+grad)


%% Train the filter
% First look up for previously saved models.
saveName = sprintf('%s/2layer_iter%d_patchSize%d_stepSize%d_pool%d_overlap%g_resize%g_numhid%d_resize_times%d', category, T, patchSize, stepSize, pool, overlap, resize_factor,num_hid,resize_times);
CompleteSavePath = sprintf('%s/%s.mat', savePath, saveName);
try 
    load(CompleteSavePath);
catch
    model = train_2layercnn(amp_train_feat,amp_train_Y,val_feat,val_Y,amp_train_gt,val_gt,overlap,filter_size,numChannels,lambda,T,optConv,patchSize,stepSize,pool,resize_array);
    
    model = train_2layercnn(amp_train_feat,amp_train_Y,val_feat,val_Y,amp_train_gt,val_gt,overlap,filter_size,numChannels,lambda,T,optConv,patchSize,stepSize,pool,resize_array);
    save(CompleteSavePath, 'model');
end

%% TEST part
pred_bbox = predict_cnn2(train_feat,filter_size,length(train_feat),model,optConv, resize_times, resize_array);
for j=1:length(pred_bbox)
    if isempty(pred_bbox{j})
        continue;
    end
    pred_bbox{j}(:,1) = (pred_bbox{j}(:,1)-1)*pool*stepSize+1;
    pred_bbox{j}(:,2) = (pred_bbox{j}(:,2)-1)*pool*stepSize+1;
    pred_bbox{j}(:,3) = (pred_bbox{j}(:,3)-1)*pool*stepSize+1;
    pred_bbox{j}(:,4) = (pred_bbox{j}(:,4)-1)*pool*stepSize+1;
end
[acc ap] = eval_cnn(pred_bbox,train_gt,0.5,'ap')

pred_bbox = predict_cnn2(val_feat,filter_size,length(val_feat),model,optConv, resize_times, resize_array);
for j=1:length(pred_bbox)
    if isempty(pred_bbox{j})
        continue;
    end
    pred_bbox{j}(:,1) = (pred_bbox{j}(:,1)-1)*pool*stepSize+1;
    pred_bbox{j}(:,2) = (pred_bbox{j}(:,2)-1)*pool*stepSize+1;
    pred_bbox{j}(:,3) = (pred_bbox{j}(:,3)-1)*pool*stepSize+1;
    pred_bbox{j}(:,4) = (pred_bbox{j}(:,4)-1)*pool*stepSize+1;
end
[acc ap] = eval_cnn(pred_bbox,val_gt,0.5,'ap')

pred_bbox = predict_cnn2(test_feat,filter_size,length(test_feat),model,optConv, resize_times, resize_array);
for j=1:length(pred_bbox)
    if isempty(pred_bbox{j})
        continue;
    end
    pred_bbox{j}(:,1) = (pred_bbox{j}(:,1)-1)*pool*stepSize+1;
    pred_bbox{j}(:,2) = (pred_bbox{j}(:,2)-1)*pool*stepSize+1;
    pred_bbox{j}(:,3) = (pred_bbox{j}(:,3)-1)*pool*stepSize+1;
    pred_bbox{j}(:,4) = (pred_bbox{j}(:,4)-1)*pool*stepSize+1;
end
[acc ap] = eval_cnn(pred_bbox,test_gt,0.5,'ap')

saveName = sprintf('%s/pc_rc_2layer_iter%d_patchSize%d_stepSize%d_pool%d_overlap%g_resize%g_resize_times%d', category, T, patchSize, stepSize, pool, overlap, resize_factor, resize_times);
CompleteSavePath = sprintf('%s/%s.mat', savePath, saveName);
save(CompleteSavePath,'acc','ap');
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
visualizeFilter(model.W, num_hid);

  
function visualizeFilter(feat, num_hid)
% Visualize higher level features
colormap(gray);
for j=1:num_hid
    subplot(ceil(sqrt(num_hid)),ceil(sqrt(num_hid)),j);
    imagesc(feat(:,:,j));
end

function [Y gt] = gety(I,gt_bndbox,fSize,o,gs)

[h, w, ~] = size(I);

offsetX = 1;
offsetY = 1;
% [r1 c1] = meshgrid(offsetY + fSize(1)/2 : gs : h-fSize(1)/2 + 1,...
%     offsetX + fSize(2)/2 : gs : w-fSize(2)/2 + 1);

[r1 c1] = meshgrid(offsetY : gs : (h-fSize(1) + 1),...
    offsetX : gs : (w-fSize(2) + 1));

Y = ones(length(unique(r1)),length(unique(c1)))-2;
s = size(Y);
r1 = r1(:);
c1 = c1(:);
r2 = r1+fSize(1)-1;
c2 = c1+fSize(2)-1;
bbox = [c1 r1 c2 r2];

gt = gt_bndbox;

% transform bbox from kmeans feature coordinate to real pixel corr

for i=1:size(gt_bndbox,1)
    
    idx = (boxoverlap(bbox,gt_bndbox(i,:)) > o);
    b = bbox(idx,:);
    if isempty(b)
        continue;
%         error('empty b');
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

function [pos, neg] = extract_posneg(I,filter_size,gs,nnpi,gt,omax)
[h w ~] = size(I);
pos = {};
neg = {};
if isempty(gt.BB)
    return;
end
[gridY gridX] = meshgrid(1:gs:h-filter_size(1)+1,1:gs:w-filter_size(2)+1);
gridX = gridX(:);
gridY = gridY(:);
bbox = [gridX gridY gridX+filter_size(2)-1 gridY+filter_size(1)-1];
pos_idx = zeros(length(gridX),1);
neg_idx = zeros(length(gridX),1);
for i=1:length(gt)
    o = boxoverlap(bbox,gt.BB(i,:));
    pos_idx(o >= omax) = 1;
    neg_idx(o < .5) = 1;
end
pos_idx = find(pos_idx==1);
neg_idx = find(neg_idx==1);
for i=1:length(pos_idx)
    bb = bbox(pos_idx(i),:);
    pos{i} = I(bb(2):bb(4),bb(1):bb(3),:);
end

neg_idx = datasample(neg_idx,nnpi);
for i=1:length(neg_idx)
    bb = bbox(neg_idx(i),:);
    neg{i} = I(bb(2):bb(4),bb(1):bb(3),:);
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