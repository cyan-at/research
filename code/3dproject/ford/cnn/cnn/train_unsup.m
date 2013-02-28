function unsupObj = train_unsup(IMAGES, num_hid, maxIter, pyramid, patchSize)
addpath /mnt/neocortex/scratch/kihyuks/library/Display_Networks/;
addpath(genpath('/mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/recognition'))

if ~exist('num_hid','var'), num_hid = 128; end
if ~exist('maxIter','var'), maxIter = 300; end
if ~exist('pyramid','var'), pyramid = 3; end
if ~exist('patchSize','var'), patchSize = 12; end % comment: consider smaller patchSize
if ~exist('img_dir','var'),
    %     img_dir = '/mnt/neocortex/scratch/norrathe/vocalcord/data/patch_data/VID007 Positive Images (Original) (Resized)';
    img_dir = '/mnt/neocortex/scratch/norrathe/pascal_data/patches/train/pos';
end

%%% extract patches
numPatches = 100000; % comment: consider increasing the # of patches as well
numImages = length(IMAGES);
numSamplePerImage = ceil(numPatches/numImages);
numSample = numSamplePerImage*(numImages);
patch = zeros(patchSize*patchSize*size(IMAGES{1},3),numSample); % 3 for color feature, dimension x numSample
k = 0;
for i = 1:numImages,
    I = im2double(IMAGES{i});
    [rows, cols, ~] = size(I);
    for j = 1:numSamplePerImage,
        k = k + 1;
        rowstart = randi(rows-patchSize+1);
        colstart = randi(cols-patchSize+1);
        rowidx = rowstart:rowstart+patchSize-1;
        colidx = colstart:colstart+patchSize-1;
        subpatch = I(rowidx,colidx,:);
        patch(:,k) = subpatch(:);
    end
end
patch = patch(:,randsample(size(patch,2),numPatches));

%%% ZCA and display patches
[patch, M, P] = ZCA(patch);
if size(IMAGES{1},3) == 3
    figure; display_network_nonsquare_color(patch(:,1:100));
else
    figure; display_network_nonsquare(patch(:,1:100));
end

%%% train Kmeans on ZCAed patches
unsupObj = KMeansTri(maxIter, num_hid, pyramid);
unsupObj.train(patch);
if size(IMAGES{1},3) == 3
    figure; display_network_nonsquare_color(unsupObj.center);
else
    figure; display_network_nonsquare(unsupObj.center);
end

end

function [patches M P] = ZCA(patches,eps)  % ZCA code in receptive field, need to unify these whitening codes afterwards
if ~exist('eps','var'), eps = 1e-2; end
patches = patches';
M = mean(patches);
C = cov(patches);
[V,D] = eig(C);
P = V * diag(sqrt(1./(diag(D)+eps))) * V';
patches = bsxfun(@minus, patches, M) * P;
patches = patches';
end

