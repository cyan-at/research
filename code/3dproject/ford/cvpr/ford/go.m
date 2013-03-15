%% routine imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath('/mnt/neocortex/scratch/norrathe/BSR_source/grouping/lib');
%remove the path for cnn detections gradient
rmpath('/mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn');
%% params
addpath ./kdes_code
run_id='01';
rootdir='/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/cvpr/ford';
imgdir=[rootdir '/images/'];
labeldir=[rootdir '/labels/']; %nonexistent
basesegdir=[rootdir '/segmentation/ucm_base/'];
ucm_dir=[rootdir '/segmentation/ucm_gpb'];
basefeatdir=[rootdir '/features/base/'];
system(['mkdir -p ' basefeatdir]);
savedir=[rootdir '/save'];
system(['mkdir -p ' savedir]);

%% compute features

pngs = catalogue(imgdir,'png');

% temp
nframe=length(pngs);
% compute kdes features on base-level superpixels
gkdes_words=load_kdes_words('gkdes',0.001);
rgbkdes_words=load_kdes_words('rgbkdes',0.01);
lbpkdes_words=load_kdes_words('lbpkdes',0.01);
disp('computing kdes features for base superpixels... (could take a while)');

% run matlabpool first
for i=min(nframe,length(pngs)):-1:1
    pngfile = cell2mat(pngs(i));
    disp(pngfile);
    [~,id,~] = fileparts(pngfile);
    savefile=[basefeatdir '/' id '.mat'];
    if exist(savefile,'file'), continue; end;
    
    disp('loading data');
    img=im2double(imread([imgdir '/' id '.png']));
    segfile = [basesegdir '/' id '.mat'];
    if (~exist(segfile,'file')); continue; end;
    data=load(segfile,'seg');
    seg=data.seg;
    
    % compute kdes features on seg
    disp('compute kde features');
    feaSet=gkdes_dense( img, gkdes_words.params, gkdes_words.grid_space );
    feaSet.feaArr{1}=single(feaSet.feaArr{1});
    gkdes=cksvd_emk_seg( feaSet, gkdes_words.words, gkdes_words.G, seg, gkdes_words.ktype, gkdes_words.kparam );
    
    feaSet=rgbkdes_dense( img, rgbkdes_words.params, rgbkdes_words.grid_space );
    feaSet.feaArr{1}=single(feaSet.feaArr{1});
    rgbkdes=cksvd_emk_seg( feaSet, rgbkdes_words.words, rgbkdes_words.G, seg, rgbkdes_words.ktype, rgbkdes_words.kparam );
    
    feaSet=lbpkdes_dense( img, lbpkdes_words.params, lbpkdes_words.grid_space );
    feaSet.feaArr{1}=single(feaSet.feaArr{1});
    lbpkdes=cksvd_emk_seg( feaSet, lbpkdes_words.words, lbpkdes_words.G, seg, lbpkdes_words.ktype, lbpkdes_words.kparam );
    
    f_ex=region_features_extra_rgb( seg );
    
    gkdes=single(gkdes); rgbkdes=single(rgbkdes); lbpkdes=single(lbpkdes);
    
    save_feature_rgb(savefile,gkdes,rgbkdes,lbpkdes,f_ex);
end

