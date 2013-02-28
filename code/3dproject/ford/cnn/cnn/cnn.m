function cnn

% N = numImages
% IMAGES
addpath ../detection/
addpath /afs/umich.edu/user/h/o/honglak/Library/convolution/IPP-conv2-mex/
%% Hyper parameters

num_total_images = 150;
num_train_images = 50;
T = 100000;
lambda = .01;
overlap = .8;
scale = [(1/1.2)^2 1/1.2 1 1.2 1.2^2]*.5;
filter_size = [199 71];
% t0 = 0.1
% n0 = 1

%% Prepare data
root_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/pos';
annot_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/annotations';

dataBase = dir(root_dir);
dataBase = dataBase(3:end);

IMAGES = cell(1,num_total_images*length(scale));
bndbox = cell(1,num_total_images*length(scale));
Y = cell(1,num_total_images);
% bbox_size = [0 0 0];
for i=1:num_total_images
    [~,name] = fileparts(dataBase(i).name);
    for k=1:length(scale)
        gt_idx = (i-1)*length(scale)+k;
        IMAGES{gt_idx} = get_image(sprintf('%s/%s.png',root_dir,name), 0, scale(k));

        % INRIA dataset
        t = textread(sprintf('%s/%s.txt',annot_dir,name),'%s');
        bbox_idx = find(strcmp(t,'(Xmin,')==1);
        bndbox{gt_idx} = zeros(length(bbox_idx),4);
        for j=1:length(bbox_idx)
            bndbox{gt_idx}(j,:) = scale(k)*[sscanf(t{bbox_idx(j)+6},'(%d,') sscanf(t{bbox_idx(j)+7},'%d)') sscanf(t{bbox_idx(j)+9},'(%d,') sscanf(t{bbox_idx(j)+10},'%d)')];
        end

%         bb = bndbox{gt_idx};
%         imshow(IMAGES{gt_idx});
%         showboxes(uint8(IMAGES{gt_idx}*255),bb);
%         bbox_size = bbox_size + [sum(bb(:,4)-bb(:,2)) sum(bb(:,3)-bb(:,1)) size(bb,1)];
    end
end

% bbox_size = bbox_size/bbox_size(3);
% filter_size = round(bbox_size(1:2));

% get Y label for each image
num_train_inv = 0;
for i=1:num_total_images*length(scale)
    [h w ~] = size(IMAGES{i});
    if h < filter_size(1) || w < filter_size(2)
        IMAGES{i} = [];
        Y{i} = [];
        fprintf('Image %d is smaller than filter: (%d,%d) vs (%d,%d)\n',i,h,w,filter_size(1),filter_size(2));
        if i < num_train_images
            num_train_inv = num_train_inv+1;
        end
        continue;
    end
    Y{i} = gety(IMAGES{i},bndbox{i},filter_size,overlap);
end

num_train_inv

%% Train the filter
W = 2*rand([filter_size 3])-1;
b = 2*rand(3,1)-1;


avg_cost = 0;
for t=0:T
    l = learn_rate(t);
    old_cost = avg_cost;
    avg_cost = 0;
        
        
        for n=1:num_train_images*length(scale)
            if isempty(IMAGES{n})
                continue;
            end
%             theta = roll_theta(W,b);
            [cost wgrad bgrad] = cnn_color_gradient(IMAGES{n},Y{n},W,b,filter_size,lambda);
%             [wgrad bgrad] = unroll_theta(theta_grad,filter_size);
            W = W-l*(wgrad+lambda*W/(num_train_images*length(scale)-num_train_inv));
            b = b-l*bgrad;
            avg_cost = avg_cost+cost/(num_train_images*length(scale)-num_train_inv);
        end
    diff = norm(avg_cost-old_cost)/norm(avg_cost+old_cost);
    fprintf('time t = %d, avg cost = %g, diff = %g\n',t,avg_cost,diff);
    if diff < 1e-7
        break;
    end
end
%% TEST part - to do

num_test = num_total_images*length(scale)-num_train_images*length(scale)-1;
bbox = cell(num_test,1);
gt_bbox = cell(num_test,1);
for i=num_train_images*length(scale)+1:num_total_images*length(scale)
    I = IMAGES{i};
    if isempty(I)
        continue;
    end
    a = 0;
    for j=1:3
        a = a+double(conv2(gdouble(I(:,:,j)),gdouble(rot90(W(:,:,j),2)),'valid')+b(j));
    end
    a = double(a);
    [r c] = find(a>0);
    bbox{i-num_train_images*length(scale)} = [c r c+fSize(2)-1 r+fSize(1)-1];
    gt_bbox{i-num_train_images*length(scale)} = bndbox{i};
end

function img = get_image(impath, opt_gray, scale)
img = imread(impath);
if scale ~= 1
    img = imresize(img,scale);
end
if opt_gray
    img = rgb2gray(img);
end
img = im2double(img);

function n = learn_rate(t,t0,n0)
if nargin == 1
    t0 = 10;
    n0 = 1;
end
n = n0/(1+t/t0);

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
    Y(b(:,2),b(:,1)) = 1;
end

% checking, wrong now, only one side is correct
% [r c] = find(Y==1);
% bbox = [c r c+fSize(2)-1 r+fSize(1)-1];
% imshow(I);
% showboxes(uint8(I*255),bbox)

if size(Y) ~= s
    error('eee');
end
