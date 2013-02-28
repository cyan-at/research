function visualizeKmeansPixelLevel(img,center,patchSize,stepSize,numCentroids,num)
img = im2double(img);

[im_h, im_w, im_ch] = size(img);

[gridX, gridY] = meshgrid(1:stepSize:im_w-patchSize+1, 1:stepSize:im_h-patchSize+1);
gridX = gridX(:);
gridY = gridY(:);
bbox = cell(numCentroids,1);
patch = zeros(patchSize*patchSize*size(img,3),length(gridX));
for i=1:length(gridX)
    tmp = img(gridY(i):gridY(i)+patchSize-1,gridX(i):gridX(i)+patchSize-1,:);
    patch(:,i) = tmp(:);
end
patch = ZCA(patch);
for i=1:length(gridX)
    % Assign samples to the nearest centers
    [~,label] = max(bsxfun(@minus, center'*patch(:,i), 0.5*sum(center.^2, 1)')); 
    bbox{label} = [bbox{label}; [gridX(i) gridY(i) gridX(i)+patchSize-1 gridY(i)+patchSize-1]];
end
if exist('num','var')
    showboxes(img,bbox{num});
else
    for i=1:numCentroids
        subplot(ceil(sqrt(numCentroids)),ceil(sqrt(numCentroids)),i);
        showboxes(img,bbox{i});
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