function feat = max_pooling(I,centroids,patchSize,stepSize,useJacket,pool)
I = im2double(I);
activation = convolveKmeans(I,patchSize,centroids,stepSize,useJacket);
feat = activation;
if ~exist('pool','var') || pool == 1
    return;
end
[h, w, c] = size(activation);
% pool = 2;


% x = 1:w-block_size(2)+1;
% y = 1:h-block_size(1)+1;
% [gridX, gridY] = meshgrid(x,y);
% gridX = gridX(:);
% gridY = gridY(:);
% feat = zeros(length(y),length(x),c);
% for i=1:length(gridX)
%     feat(gridY(i),gridX(i),:) = max(max(activation(gridY(i):gridY(i)+block_size(1)-1,gridX(i):gridX(i)+block_size(2)-1,:), [], 2));
% end

tic
x = 1:pool:w-pool+1;
y = 1:pool:h-pool+1;
[gridX, gridY] = meshgrid(x,y);
gridX = gridX(:);
gridY = gridY(:);
feat = zeros(length(y),length(x),c);
for i=1:length(gridX)
    feat((gridY(i)-1)/pool+1,(gridX(i)-1)/pool+1,:) = max(max(activation(gridY(i):gridY(i)+pool-1,gridX(i):gridX(i)+pool-1,:), [], 2));
end
toc