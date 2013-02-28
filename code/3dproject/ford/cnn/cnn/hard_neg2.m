function neg = hard_neg2(IMAGES,model,gt,filter_size,overlap)

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
        bbox( (ov > overlap),:) = [];
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