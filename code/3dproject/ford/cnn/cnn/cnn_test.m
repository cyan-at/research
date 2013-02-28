function [ output_args ] = cnn_test( )

%%
addpath ../detection/
addpath /afs/umich.edu/user/h/o/honglak/Library/convolution/IPP-conv2-mex/

savePath = '/mnt/neocortex/scratch/linshu/3d_car/cnn/models';
% if ~exist(savePath, 'dir')
%     mkdir(savePath);
% end

use_hog = 1;
patchSize = 16;
num_iter = 2000;
lambda = .01;
overlap = .8;

%%

% root_dir = '/mnt/neocortex/scratch/linshu/3d_car/cnn/face_single';
% annot_dir = '/mnt/neocortex/scratch/linshu/3d_car/cnn/face_single_annot';
root_dir = '/mnt/neocortex/data/101_ObjectCategories/Faces';
annot_dir = '/mnt/neocortex/data/101_ObjectCategories_tightbb/Annotations/Faces';

imagebase = dir(root_dir);
imagebase = imagebase(3:end);
annotbase = dir(annot_dir);
annotbase = annotbase(3:end);

[~, img_name] = fileparts(imagebase(1).name);
the_img = imread(sprintf('%s/%s', root_dir, imagebase(10).name));
[~, annot_name] = fileparts(annotbase(1).name);
the_annot = load(sprintf('%s/%s', annot_dir, annotbase(10).name));
bndbox = [the_annot.box_coord(3), ...
     the_annot.box_coord(1), ...
     the_annot.box_coord(4), ...
     the_annot.box_coord(2)];

% Get the HOG features.
init_size = size(the_img);
img_hog = cnnHOG(the_img, patchSize);
hog_size = size(img_hog);
new_bndbox = calcResizedBndbox(init_size(1), init_size(2), bndbox, ...
	hog_size(1), hog_size(2),patchSize);
filter_size = [new_bndbox(3) - new_bndbox(1), new_bndbox(4) - new_bndbox(2)];


images = cell(1, num_iter);
annots = cell(1, num_iter);

% Prepare training data.
for i = 1 : num_iter
    
    images{i} = img_hog;
    annots{i} = new_bndbox;

end

% Get Y
the_Y = gety(images{1}, annots{1}, filter_size, overlap);
num_train_inv = 0;
for i = 1 : num_iter
	Y{i} = the_Y;
end

% Train
hog_channel = 32;
W = 2*rand([filter_size hog_channel])-1;
b = 2*rand(hog_channel,1)-1;

avg_cost = 0;
for t=0:num_iter
    l = learn_rate(t);
    old_cost = avg_cost;
    avg_cost = 0;
        
        
        for n=1:num_train_images*length(scale)
            if isempty(images{n})
                continue;
            end
%             theta = roll_theta(W,b);
            [cost wgrad bgrad] = cnn_color_gradient(images{n},Y{n},W,b,filter_size,lambda, use_hog, optJacket);
%             [wgrad bgrad] = unroll_theta(theta_grad,filter_size);
            W = W-l*(wgrad+lambda*W/(num_train_images - num_train_inv));
            b = b-l*bgrad;
            avg_cost = avg_cost+cost/(num_train_images - num_train_inv);
        end
    diff = norm(avg_cost-old_cost)/norm(avg_cost+old_cost);
    fprintf('time t = %d, avg cost = %g, diff = %g\n',t,avg_cost,diff);
    if diff < 1e-7
        break;
    end
  
end

model.W = W;
model.b = b;
saveName = sprintf('use_hog%d_patchSize%d_lambda%g_overlap%g', use_hog, patchSize, lambda, overlap);
CompleteSavePath = sprintf('%s/%s.mat', savePath, saveName);
save(CompleteSavePath, 'model');


end

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

if size(Y) ~= s
    error('eee');
end

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
end

function n = learn_rate(t,t0,n0)
if nargin == 1
    t0 = 10;
    n0 = 1;
end
n = n0/(1+t/t0);
end

