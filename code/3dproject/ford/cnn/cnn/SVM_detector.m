function SVM_detector()
addpath ../detection/
%% Hyper parameters

num_train_images = 50;
lambda_vec = 0.01;
nnpi = 2;
optConv = [];
K = 5;
overlap = 0.9;
resize_factor = .5;

%% Prepare data
root_dir = '/mnt/neocortex/data/101_ObjectCategories/Faces';
annot_dir = '/mnt/neocortex/data/101_ObjectCategories_tightbb/Annotations/Faces';
dataBase = dir(root_dir);
dataBase = dataBase(3:end);

IMAGES = cell(1,num_train_images);
bndbox = cell(1,num_train_images);
bbox_size = [0 0 0];
npos = 0;
for i=1:num_train_images
    [~,name] = fileparts(dataBase(i).name);
    I = im2double((imread(sprintf('%s/%s.jpg',root_dir,name))));
    IMAGES{i} = imresize(I,resize_factor);
    
    % Car-side dataset
    num = sscanf(name,'image_%d');
    obj = load(sprintf('%s/annotation_%04d.mat',annot_dir,num));
    bndbox{i} = obj.box_coord*resize_factor;
    bb = [bndbox{i}(:,3) bndbox{i}(:,1) bndbox{i}(:,4) bndbox{i}(:,2)];
    bndbox{i} = bb;
    bbox_size = bbox_size + [sum(bb(:,4)-bb(:,2)) sum(bb(:,3)-bb(:,1)) size(bb,1)];
    
    npos = npos+size(bb,1);
    gt(i).BB = bb;
    gt(i).det = zeros(size(bb,1),1);
    gt(i).diff = zeros(size(bb,1),1);
end

bbox_size = bbox_size/bbox_size(3);
filter_size = round(bbox_size(1:2));

%% Run detector
pos = get_pos(IMAGES,gt,filter_size,overlap);
rneg = random_neg(IMAGES,gt,nnpi,filter_size);
model = train_SVM(pos,rneg,K,lambda_vec);
old_hneg = [];
for i=1:100
    
    hneg = hard_neg(IMAGES,model,gt,filter_size);
    neg = [rneg; hneg; old_hneg];
    
    omodel = model;
    if isempty(hneg)
        break;
    end
    
    model = train_SVM(pos,neg,K,lambda_vec);
    
%     if modelcomp(model,omodel) == 1
%         break;
%     end
    
    old_hneg = hneg;
%     old_hneg = datasample(hneg,min(1000,floor(size(hneg,1)/2)));

    cost = obj_function_cost(model,IMAGES,gt,filter_size,overlap,optConv,lambda_vec)
        
%     if norm(old_cost-cost)/norm(old_cost+cost) < 1e-5
%         break;
%     end
end

cost = obj_function_cost(model,IMAGES,gt,filter_size,overlap,optConv,lambda_vec);
    
function cost = obj_function_cost(model,IMAGES,gt,filter_size,overlap,optConv,lambda)
cost = 0;
numChannels = size(IMAGES{1},3);
w = reshape(model.w(1:end-1),[filter_size(1) filter_size(2) numChannels]);
b = model.w(end);
for j=1:length(IMAGES)
    I = IMAGES{j};
    Y = gety(I,gt(j).BB,filter_size,overlap);
    a = 0;
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
    cost = cost + sum(vec(max(0,1-err).^2));
end
cost = cost + lambda*sum(w(:).*w(:))/2;

function Y = gety(I,gt_bndbox,fSize,o)
% assume I is gray scale for now
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
    Y(b(:,2),b(:,1)) = 0;
end

% checking
% [r c] = find(Y==1);
% bbox = [c r c+fSize(2)-1 r+fSize(1)-1];
% imshow(I);
% showboxes(uint8(I*255),bbox)

if size(Y) ~= s
    error('eee');
end

function cmp = modelcomp(model,omodel)
diff = norm(vec(model.w-omodel.w))/norm(vec(model.w+omodel.w))
cmp = diff < 1e-7;

function pos = get_pos(IMAGES,gt,filter_size,overlap)
num_images = length(IMAGES);
I = cell(num_images,1);
num = zeros(num_images,1);
for i=1:num_images
    fprintf('Pos: image %d\n',i);
    [im_h, im_w, numChannels] = size(IMAGES{i});
    [gridX gridY] = meshgrid(1:im_w-filter_size(2),1:im_h-filter_size(1));
    gridX = gridX(:);
    gridY = gridY(:);
    bbox = [gridX gridY gridX+filter_size(2)-1 gridY+filter_size(1)-1];
%     bbox = [gridY gridX gridY+filter_size(1)-1 gridX+filter_size(2)-1];
    for j=1:size(gt(i).BB,1)
        ov = boxoverlap(bbox,gt(i).BB(j,:));
        bbox( (ov < overlap),:) = [];
    end
    
    numPatches = size(bbox,1);
    I{i} = zeros(numPatches,filter_size(1)*filter_size(2)*numChannels);
    for j=1:numPatches
        I{i}(j,:) = vec(IMAGES{i}(bbox(j,2):bbox(j,4),bbox(j,1):bbox(j,3),:));
    end
    num(i) = numPatches;
end
pos = zeros(sum(num),filter_size(1)*filter_size(2)*size(IMAGES{1},3));
idx = 1;
for i=1:num_images
    npos = size(I{i},1);
    pos(idx:idx+npos-1,:) = I{i};
end

function neg = hard_neg(IMAGES,model,gt,filter_size)

num_images = length(IMAGES);

hard_neg = cell(num_images,1);
num = zeros(num_images,1);

% find hard negative
parfor i=1:num_images
    fprintf('Hard neg: image (%d/%d)\n',i,num_images);
    [im_h, im_w, numChannels] = size(IMAGES{i});
    [gridX gridY] = meshgrid(1:im_w-filter_size(2),1:im_h-filter_size(1));
    gridX = gridX(:);
    gridY = gridY(:);
    bbox = [gridX gridY gridX+filter_size(2)-1 gridY+filter_size(1)-1];
%     bbox = [gridY gridX gridY+filter_size(1)-1 gridX+filter_size(2)-1];
    for j=1:size(gt(i).BB,1)
        ov = boxoverlap(bbox,gt(i).BB(j,:));
        bbox( (ov > .5),:) = [];
    end
    
    numPatches = size(bbox,1);
    I = zeros(numPatches,filter_size(1)*filter_size(2)*numChannels);
    for j=1:numPatches
        I(j,:) = vec(IMAGES{i}(bbox(j,2):bbox(j,4),bbox(j,1):bbox(j,3),:));
    end
    plabel = predict_SVM(I',zeros(numPatches,1),model);
    I(plabel == 0,:) = [];
    hard_neg{i} = I;
    if isempty(I)
        num(i) = 0;
    else
        num(i) = size(I,1);
    end
end

% Merge hard neg
if sum(num) == 0
    neg = [];
    return;
end

neg = zeros(sum(num),filter_size(1)*filter_size(2)*size(IMAGES{1},3));
idx = 1;
for i=1:num_images
    num_hard_neg = size(hard_neg{i},1);
    neg(idx:idx+num_hard_neg-1,:) = hard_neg{i};
end

function label = predict_SVM(ts_fea,ts_label,model)
curdir = pwd; 
cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
                
ts_fea = double(ts_fea);
[label, ~, ~] = predict(ts_label, sparse(ts_fea), model, [], 'col');
cd(curdir);

function neg = random_neg(IMAGES,gt,nnpi,filter_size)
% nnpi = num neg per image

addpath ../detection/

neg = zeros(nnpi*length(IMAGES),filter_size(1)*filter_size(2)*size(IMAGES{1},3));
for i=1:length(IMAGES)
   [im_h, im_w, ~] = size(IMAGES{i});
   for j=1:nnpi
       while 1
           rx = randi(im_w-filter_size(2),1,1);
           ry = randi(im_h-filter_size(1),1,1);
           bbox = [rx ry rx+filter_size(2)-1 ry+filter_size(1)-1];
%            bbox = [ry rx ry+filter_size(1)-1 rx+filter_size(2)-1];
           ov = boxoverlap(gt(i).BB,bbox);
           if max(ov) < .5
               neg(nnpi*(i-1)+j,:) = vec(IMAGES{i}(bbox(2):bbox(4),bbox(1):bbox(3),:));
               break;
           end
       end
   end
end

function y = vec(x)
y = x(:);