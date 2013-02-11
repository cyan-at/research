function [ output_args ] = visualizeActivations2D(imgobj, featureType, trainedUnsupPath, trainedSvmPath)
close all;
%load dependencies
%addpath '/mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/recognition/sift'
%addpath '~/libdeepnets/trunk/3dcar_detection/recognition/';
%addpath '/mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/detection/';

load(trainedSvmPath);  % load sample svm model

C = imresize(imgobj,[256 256]); %resize the imgobj to 256 x 256

ps = 32; gs = 4;

if (strcmp(featureType, 'sift'))
    [feaSet gridX gridY] = sift(C,ps,gs);
elseif (strcmp(featureType, 'hog'))
    [feaSet gridX gridY] = calcHOG(C, ps, gs);
end
    
% feaSet.feaArr = feaSet.feaArr(:,1);

% load sample unsup model
load(trainedUnsupPath);

feaArr = feaSet.feaArr';   

size(feaArr)
size(codebook.center')

%% kmeans hard activation
 % Assign samples to the nearest centers
[~,label] = max(bsxfun(@minus, codebook.center'*feaArr', 0.5*sum(codebook.center.^2, 1)')); 
n = size(feaArr',2);
K = size(codebook.center, 2);
            
% Transform label into indicator matrix
activation = sparse(1 : n, label, 1, n, K, n)'; 
            
            
%% kmeans tri activation            
% xx = sum(feaArr.^2, 2);
% cc = sum(codebook.center' .^ 2, 2)';           
% xc = feaArr * codebook.center;
%             
% % Calculate distances.
% z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) );
%             
% % Average distance to centroids for each patch.
% mu = mean(z, 2); 
% activation = max(bsxfun(@minus, mu, z), 0)';
% clear z xx xc cc mu;


            
%% Spatial pyramid matching.
pyramid = [1];
pLevels = length(pyramid);
pBins = pyramid .^ 2;
tBins = sum(pBins);
pool = zeros(size(activation, 1), tBins);


idx = zeros(size(activation, 1),tBins);
            
if (size(feaSet.feaArr, 2) <= 0)
    pool = pool(:);
    return;
end
            
bId = 0;
for cur_level = 1 : pLevels,
    nBins = pBins(cur_level);

    wUnit = (feaSet.width) / pyramid(cur_level);
    hUnit = (feaSet.height) / pyramid(cur_level);

    % Find to which spatial bin each local descriptor
    % belongs.
    xBin = ceil(feaSet.x / wUnit);
    yBin = ceil(feaSet.y / hUnit);
    idxBin = (yBin - 1) * pyramid(cur_level) + xBin;
                
    for cur_bin = 1 : nBins,

        bId = bId + 1;
        sidxBin = find(idxBin == cur_bin);
        if isempty(sidxBin),
            continue;
        end

        % Spatial max pooling and keep track of the max index
        [pool(:,bId) idx(:,bId)] = max(activation(:, sidxBin), [], 2);
        
    end
                
end
            
if bId ~= tBins,
    error('Index number error!');
end
            
pool = pool(:);
pool = pool./sqrt(sum(pool.^2));

% pick top 10 most positive weights and trace back to
[wi, ws] = sort(model.w(1:end-1),'descend');
% gidx = idx(ws(1:5));
num_weights = 5;
bbox = cell(num_weights,1);
color = 'kbgrcy';
for i=1:5
    ws_idx = ws(i);
    allidx = find(activation(ws_idx,:) == 1);
    if isempty(allidx)
        continue;
    end
    gx = gridX(allidx);
    gy = gridY(allidx);

    % traced bounging boxes
    bbox{i} = [gy-ps/2 gx-ps/2 gy+ps/2 gx+ps/2];
end

showboxes_color(C,bbox,color);

%154,168, pool=0.082

%% classify (optional)
curdir = pwd;
cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
[pred, acc, rscore] = predict(1, sparse(pool), model, [], 'col');
           
cd(curdir)

% size of cropped image = 210x262
% size of feat.feaArr = 128x12152 (SIFT)
% size of codebook.center = 128*1000 (kmeans_tri)
% size of activation = 1000x12152
% size of pool = 1000x1
end

