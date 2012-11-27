function feaSet = generate_SIFT_features(pars, database, iter1)
%%%==============================================
%%% generate feature set (feaSet) from the image
%   feaSet.feaArr   : (128*ws^2) x numanchorpoints x num_tf
%   feaSet.x        : numanchorpoints x 1 (x-coordinate, width)
%   feaSet.y        : numanchorpoints x 1 (y-coordinate, height)
addpath(genpath('/mnt/neocortex/scratch/kihyuks/feature'));
if ~isfield(pars,'nrml_threshold'), pars.nrml_threshold = 1; end
if ~isfield(pars,'suppression'), pars.suppression = 0.2; end
spath = sprintf('%s/SIFT_%.6d.mat',pars.siftdatapath,iter1);

try
    load(spath);
catch
    %% load image and resize < maxImSize
    I_orig = imread(database.path{iter1});
    
    if ndims(I_orig) == 3, I_orig = im2double(rgb2gray(I_orig));
    else I_orig = im2double(I_orig); end
    
    %% resize to maxImSize
    [im_h, im_w] = size(I_orig);
    if max(im_h, im_w) > pars.maxImSize,
        I_orig = imresize(I_orig, pars.maxImSize/max(im_h, im_w), 'bicubic');
        [im_h, im_w] = size(I_orig);
    end;
    
    %% set the anchor points
    num_scales = length(pars.ratio);
	psmax = max(pars.pslist);
    gsmax = max(pars.gslist);
    lntmax = psmax + (pars.ws-1)*gsmax;
    
    remX = mod(im_w-lntmax/2,pars.gs);
    offsetX = floor(remX/2)+1;
    remY = mod(im_h-lntmax/2,pars.gs);
    offsetY = floor(remY/2)+1;
    [gridX,gridY] = meshgrid(offsetX+ceil(lntmax/2):pars.gs:im_w-ceil(lntmax/2)+1, offsetY+ceil(lntmax/2):pars.gs:im_h-ceil(lntmax/2)+1);
    sp_x = gridX(:) - 0.5;
    sp_y = gridY(:) - 0.5;
    
    numanchorpoints = length(sp_x);
    
    %% for each scale, extract SIFT features at multiple scales
    feaArr = zeros(128*pars.ws^2,numanchorpoints,num_scales);
    for i = 1:num_scales,
        ps = pars.pslist(i);
        gs = pars.gslist(i);
        list = floor(-(pars.ws-1)*gs/2):gs:floor((pars.ws-1)*gs/2);
        id = 0;
        for j = 1:pars.ws, % gridX
            for k = 1:pars.ws, % gridY
                id = id + 1;
                gridX_tmp = gridX + list(j);
                gridY_tmp = gridY + list(k);
                feaArr_tmp = sp_find_sift_grid(I_orig, gridX_tmp, gridY_tmp, ps, 0.8);
                feaArr_tmp = sp_normalize(feaArr_tmp,pars.nrml_threshold,pars.suppression);
                feaArr((id-1)*128+1:id*128,:,i) = feaArr_tmp';
            end
        end
    end
    feaArr = single(feaArr);
    
    %% save
    feaSet.feaArr = feaArr;
    feaSet.x = sp_x;
    feaSet.y = sp_y;
    feaSet.width = im_w;
    feaSet.height = im_h;
    save(spath,'feaSet');
end
return;
