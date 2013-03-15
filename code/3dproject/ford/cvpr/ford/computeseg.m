function computeseg(start, duration)
%% routine imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath('/mnt/neocortex/scratch/norrathe/BSR_source/grouping/lib');
%% Compute globalPb and hierarchical segmentation for an example image.
images = dir('images/*.png');
startfrom = 0;
found = false; since = 0;
for i=length(images):-1:1;
    [~, im_name, ~] = fileparts(images(i).name);
    if (exist(['segmentation/ucm_base/' im_name '.mat'],'file'))
        continue;
    end;
    if (~strcmp(start,''))
    if (found)
        since = since + 1;
    else
        if strcmp(im_name, start)
            found = true;
            since = since + 1;
        end
    end
    if (since <= startfrom+duration & since > startfrom)
    else
        continue;
    end
    end
    disp(im_name);
    %% 1. compute globalPb on a BSDS image (5Gb of RAM required)
    clearvars -except im_name images found startfrom duration since start; close all; clc;
    imgFile = ['images/' im_name '.png'];
    outFile = ['images/' im_name '_gPb.mat'];
    gPb_orient = globalPb(imgFile, outFile);
    %% 2. compute Hierarchical Regions
    
    % for boundaries
    disp('boundaries');
    ucm = contours2ucm(gPb_orient, 'imageSize');
    imwrite(ucm,['images/' im_name '_ucm.bmp']);
    
    % for regions 
    disp('regions');
    ucm2 = contours2ucm(gPb_orient, 'doubleSize');
    ensure('segmentation/ucm_gpb');
    save(['segmentation/ucm_gpb/' im_name '.mat'],'ucm2');
    % save(['data/' im_name '_ucm2.mat'],'ucm2');
    
    %% 3. usage example
    disp('usage');
    clearvars -except im_name images found startfrom duration since start; close all; clc;
    %load double sized ucm
    load(['segmentation/ucm_gpb/' im_name '.mat'],'ucm2');
    % convert ucm to the size of the original image
    ucm = ucm2(3:2:end, 3:2:end);
    % get the boundaries of segmentation at scale k in range [0 1]
    k = 0.02;
    bdry = (ucm >= k);
    % get superpixels at scale k without boundaries:
    labels2 = bwlabel(ucm2 <= k);
    seg = labels2(2:2:end, 2:2:end)-1;

%     figure;imshow(['images/' im_name  '.png']);
%     figure;imshow(ucm);
%     figure;imshow(bdry);
%     figure;imshow(seg,[]);colormap(jet);
    
    ensure('./segmentation/ucm_base');
    save(['segmentation/ucm_base/' im_name '.mat'],'seg');
end
