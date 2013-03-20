function computeseg2(workingPath,schemeType)
%rest of cvpr pipeline, much faster than the other part
%% routine imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath('/mnt/neocortex/scratch/norrathe/BSR_source/grouping/lib');
%remove the path for cnn detections gradient
rmpath('/mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn');
%% params
addpath ./kdes_code
imgdir=[workingPath 'images/'];
basesegdir=[workingPath '/segmentation/ucm_base/'];
ucm_dir=[workingPath '/segmentation/ucm_gpb/'];
basefeatdir=[workingPath '/features/base/'];
run_segmentation_tree=1;
k_ucm_all=[0.04 0.06 0.08 0.10 0.15];

system(['mkdir -p ' basefeatdir]);
savedir=[workingPath '/save'];
system(['mkdir -p ' savedir]);

%% compute features
pngs = catalogue(imgdir,'png');
nframe=length(pngs);
% compute kdes features on base-level superpixels
gkdes_words=load_kdes_words('gkdes',0.001);
rgbkdes_words=load_kdes_words('rgbkdes',0.01);
lbpkdes_words=load_kdes_words('lbpkdes',0.01);
disp('computing kdes features for base superpixels... (could take a while)');
% run matlabpool first

if (schemeType == 1)
    scheme = 1:2:min(nframe,length(pngs));
elseif (schemeType == 2)
    scheme = 2:2:min(nframe,length(pngs));
elseif (schemeType == 3)
    scheme = min(nframe,length(pngs)):-2:1;
else
    scheme = min(nframe,length(pngs))-1:-2:1;
end

for i=scheme
    pngfile = cell2mat(pngs(i));
    disp(pngfile);
    [~,id,~] = fileparts(pngfile);
    savefile=[basefeatdir '/' id '.mat'];
    %if exist(savefile,'file'), continue; end;
    
    disp('loading data');
    img=im2double(imread([imgdir '/' id '.png']));
    segfile = [basesegdir '/' id '.mat'];
    %if (~exist(segfile,'file')); continue; end;
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

    if run_segmentation_tree,
        nlevel=length(k_ucm_all);
        accus=zeros(nlevel,1);
        for ilevel=1:nlevel,
            k_ucm=k_ucm_all(ilevel);
            k_ucm=round(k_ucm*100)/100;
            k_ucm_id=num2str(k_ucm*100,'%02d');
            segdir=[workingPath '/segmentation/ucm' k_ucm_id];
            ensure(segdir);
            halfsize=findstr(ucm_dir,'half');
            load([ucm_dir '/' id '.mat'],'ucm2');
            seg=bwlabel( ucm2<=k_ucm );
            seg=seg(2:2:end,2:2:end)-1;
            if halfsize, seg=imresize(seg,2,'nearest'); end;
            save([segdir '/' id '.mat'],'seg');
        end
        
        savefile=[workingPath '/segmentation/map_segmentation_ks.mat'];
        disp('computing mappings between segmentations...');
        nsegs=zeros(nframe,nlevel);
        maps=cell(nframe,nlevel);
        
        k_ucm=k_ucm_all(1);
        ucm_id=num2str( round(k_ucm*100),'%02d' );
        segdir_1=[workingPath 'segmentation/ucm' ucm_id];
        load([segdir_1 '/' id '.mat'],'seg');
        seg0=seg;
        nseg0=max(seg(:))+1;
        nsegs(i,1)=nseg0;
        for ilevel=2:nlevel,
            k_ucm=k_ucm_all(ilevel);
            ucm_id=num2str( round(k_ucm*100),'%02d' );
            segdir_k=[workingPath 'segmentation/ucm' ucm_id];
            load([segdir_k '/' id '.mat'],'seg');
            nsegs(i,ilevel)=max(seg(:))+1;
            wseg0 = get_kdes_weight_seg(seg0, 2, 16 );
            [~,~,map] = features_merge_segments( zeros(nseg0,1), seg0, wseg0, seg );
            maps{i,ilevel}=map;
        end
        save(savefile,'nsegs','maps');        
    end
end
end
