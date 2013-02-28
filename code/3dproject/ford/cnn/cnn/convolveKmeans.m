function activation = convolveKmeans(I,patchSize,centroids,stepSize,useJacket)


[im_h, im_w, ~] = size(I);
% if useJacket == 'J'
%     tic
%     activation = kmeans_jacket(I,patchSize,centroids,stepSize,useJacket);
%     toc
% else
    tic
    addpath ../recognition/ObjOriented/
    feat = calcPixelsSimple(I, patchSize, stepSize);
    [feat.feaArr, M, P] = ZCA(feat.feaArr);
    activation = computeActivation(centroids,feat.feaArr);
    toc
% end

% remX = mod(im_w - patchSize/2, stepSize);
% offsetX = floor(remX / 2) + 1;
% remY = mod(im_h - patchSize/2, stepSize);
% offsetY = floor(remY / 2) + 1;
offsetX = 1;
offsetY = 1;
activation = reshape(activation,[ceil((im_h-patchSize + 2 - offsetY)/stepSize),ceil((im_w-patchSize + 2 - offsetX)/stepSize),size(centroids,2)]);
% norm(act(:)-activation(:))/norm(act(:)+activation(:))

function [patches M P] = ZCA(patches,eps)  % ZCA code in receptive field, need to unify these whitening codes afterwards
if ~exist('eps','var'), eps = 1e-2; end
patches = patches';
M = mean(patches);
C = cov(patches);
[V,D] = eig(C);
P = V * diag(sqrt(1./(diag(D)+eps))) * V';
patches = bsxfun(@minus, patches, M) * P;
patches = patches';


function activation = kmeans_jacket(I,patchSize,centroids,stepSize,optConv)
[im_h, im_w, ~] = size(I);
xx = 0;
for i=1:size(I,3)
    if optConv == 'J'
        xx = xx+double(conv2(gdouble(I(:,:,i)).^2,gdouble(ones(patchSize,patchSize)),'valid'));
    else
        xx = xx+conv2(I(:,:,i).^2,ones(patchSize,patchSize),'valid');
    end
end

% remX = mod(im_w - patchSize/2, stepSize);
% offsetX = floor(remX / 2) + 1;
% remY = mod(im_h - patchSize/2, stepSize);
% offsetY = floor(remY / 2) + 1;
offsetX = 1;
offsetY = 1;
col = offsetX : stepSize : im_w-patchSize + 1;
row = offsetY : stepSize : im_h-patchSize + 1;
xx = xx(row,col);
xx = xx(:);

numpatches = length(row)*length(col);
xc = zeros(numpatches,size(centroids,2));


for i=1:size(centroids,2)
    ci = reshape(centroids(:,i),patchSize,patchSize,size(I,3));
    s=0;
    for j=1:size(I,3)
        if optConv == 'J'
            s = s+double(conv2(gdouble(I(:,:,j)),gdouble(rot90(ci(:,:,j),2)),'valid'));
        else
            s = s+conv2(I(:,:,j),rot90(ci(:,:,j),2),'valid');
        end
    end
    s = s(row,col);
    xc(:,i) = s(:);
end
cc=sum(centroids.^2,1);

% Calculate distances.
z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) );
            
 % Average distance to centroids for each patch.
mu = mean(z, 2); 
activation = max(bsxfun(@minus, mu, z), 0); % Spatial pyramid matching.
activation = reshape(activation,[length(row),length(col),size(centroids,2)]);


        function activation = computeActivation(center, feat)
            
            patches = feat';    % 225x768       
            xx = sum(patches.^2, 2); %225x1
            cc = sum(center' .^ 2, 2)';           
            xc = patches * center;
            
            % Calculate distances.
            z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) );
            
            % Average distance to centroids for each patch.
            mu = mean(z, 2); 
            activation = max(bsxfun(@minus, mu, z), 0);
            
    