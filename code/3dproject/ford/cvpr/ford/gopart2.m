%% routine imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath('/mnt/neocortex/scratch/norrathe/BSR_source/grouping/lib');
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
nframe=length(pngs);

run_segmentation_tree=1;
k_ucm_all=[0.04 0.06 0.08 0.10 0.15];
if run_segmentation_tree,
    nlevel=length(k_ucm_all);
    accus=zeros(nlevel,1);
    for ilevel=1:nlevel,
        k_ucm=k_ucm_all(ilevel);
        k_ucm=round(k_ucm*100)/100;
        k_ucm_id=num2str(k_ucm*100,'%02d');
        segdir=[rootdir '/segmentation/ucm' k_ucm_id];
%         if ~exist(segdir),
            system(['mkdir -p ' segdir]);
            halfsize=findstr(ucm_dir,'half');
            for ii=1:nframe,
                pngfile = cell2mat(pngs(ii));
                disp(pngfile);
                [~,id,~] = fileparts(pngfile);
                load([ucm_dir '/' id '.mat'],'ucm2');
                seg=bwlabel( ucm2<=k_ucm );
                seg=seg(2:2:end,2:2:end)-1;
                if halfsize, seg=imresize(seg,2,'nearest'); end;
                save([segdir '/' id '.mat'],'seg');
            end
%         end
    end
    
    nlevel=length(k_ucm_all);
    savefile=[rootdir '/segmentation/map_segmentation_ks.mat'];
%     if ~exist(savefile),
        disp('computing mappings between segmentations...');
        nsegs=zeros(nframe,nlevel);
        maps=cell(nframe,nlevel);
        for ii=1:nframe,
            pngfile = cell2mat(pngs(ii));
            disp(pngfile);
            [~,id,~] = fileparts(pngfile);
            k_ucm=k_ucm_all(1);
            ucm_id=num2str( round(k_ucm*100),'%02d' );
            segdir_1=[rootdir '/segmentation/ucm' ucm_id];
            load([segdir_1 '/' id '.mat'],'seg');
            seg0=seg;
            nseg0=max(seg(:))+1;
            nsegs(ii,1)=nseg0;
            for ilevel=2:nlevel,
                k_ucm=k_ucm_all(ilevel);
                ucm_id=num2str( round(k_ucm*100),'%02d' );
                segdir_k=[rootdir '/segmentation/ucm' ucm_id];
                load([segdir_k '/' id '.mat'],'seg');
                nsegs(ii,ilevel)=max(seg(:))+1;
                wseg0 = get_kdes_weight_seg(seg0, 2, 16 );
                [dummy,dummy,map] = features_merge_segments( zeros(nseg0,1), seg0, wseg0, seg );
                maps{ii,ilevel}=map;
            end
            %if mod(ii,50)==0, disp(id); end;
        end
        save(savefile,'nsegs','maps');
%     else
        load(savefile,'nsegs','maps');
%     end
end