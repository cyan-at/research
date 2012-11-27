function rbm_feaext(hbias,W,pyramid,pars,database,iter1,exfdpath,optpooling)
try
    load(sprintf('%s/%.5d_fd.mat',exfdpath,iter1),'feature','label');
catch
    % generate SIFT features
    feaSet = generate_SIFT_features(pars, database, iter1);
    % pool the RBM features
    feature = pooling(feaSet, hbias, W, pyramid, pars, optpooling);
    label = database.label(iter1);
    save(sprintf('%s/%.5d_fd.mat',exfdpath,iter1),'feature','label');
end
return;

function pool = pooling(feaSet, hbias, W, pyramid, pars, optpooling)
%=====================================

feaSet.width = double(feaSet.width);
feaSet.height = double(feaSet.height);
img_width = feaSet.width;
img_height = feaSet.height;

% convert into macrofeatures
% [feat,sp_x,sp_y] = macrofeature_patchgen_MS_for_test(feaSet,pars);
feat = feaSet.feaArr;
[~,batchsize,numscale] = size(feat);
feat = reshape(feat,size(feat,1),batchsize*numscale);
sp_x = feaSet.x;
sp_y = feaSet.y;

rbm_codes = double(sigmoid(1/pars.sigma*(W'*GPUsingle(feat) + repmat(hbias, 1, size(feat,2)))));
rbm_codes = reshape(rbm_codes,size(rbm_codes,1),batchsize,numscale);
if strcmp(optpooling,'sum'), 
    rbm_codes = sum(rbm_codes,3);
elseif strcmp(optpooling,'max'), 
    rbm_codes = max(rbm_codes,[],3); 
end

%% spatial pyramid matching
pLevels = length(pyramid);
pBins = pyramid.^2;
tBins = sum(pBins);

pool = zeros(pars.num_hid, tBins);
bId = 0;
for iter1 = 1:pLevels,
    nBins = pBins(iter1);
    
    wUnit = (img_width) / pyramid(iter1);
    hUnit = (img_height) / pyramid(iter1);
    
    % find to which spatial bin each local descriptor belongs
    xBin = ceil(sp_x / wUnit);
    yBin = ceil(sp_y / hUnit);
    idxBin = (yBin - 1)*pyramid(iter1) + xBin;
    
    for iter2 = 1:nBins,
        bId = bId + 1;
        sidxBin = find(idxBin == iter2);
        if isempty(sidxBin),
            continue;
        end
        pool(:,bId) = max(rbm_codes(:, sidxBin), [], 2);
    end
end

if bId ~= tBins,
    error('Index number error!');
end

pool = pool(:);
pool = pool./sqrt(sum(pool.^2));

return;