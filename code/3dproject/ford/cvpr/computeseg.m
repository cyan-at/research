function computeseg(workingPath)
%% routine imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath('/mnt/neocortex/scratch/norrathe/BSR_source/grouping/lib');

%parameters
ensure(workingPath);
segbaseDir = strcat(workingPath,'segmentation/ucm_base/');
seggpbDir = strcat(workingPath,'segmentation/ucm_gpb/');
imgDir = strcat(workingPath,'images/');
ensure(segbaseDir);
ensure(seggpbDir);
ensure(imgDir);

%% Compute globalPb and hierarchical segmentation for an example image.
images = catalogue(imgDir,'png');
scheme = length(images)-1:-2:1;
for i=scheme
    [~,im_name,~] = fileparts(cell2mat(images(i)));
    if (exist(strcat(segbaseDir,im_name,'.mat'),'file'))
        continue;
    end;
    disp(im_name);
    %% 1. compute globalPb on a BSDS image (5Gb of RAM required)
    imgFile = [imgDir im_name '.png'];
    outFile = [imgDir im_name '_gPb.mat'];
    gPb_orient = globalPb(imgFile, outFile);
    %% 2. compute Hierarchical Regions
    % for boundaries
    disp('boundaries');
    ucm = contours2ucm(gPb_orient, 'imageSize');
    imwrite(ucm,[imgDir im_name '_ucm.bmp']);
    % for regions 
    disp('regions');
    ucm2 = contours2ucm(gPb_orient, 'doubleSize');
    save([seggpbDir im_name '.mat'],'ucm2');
    % save(['data/' im_name '_ucm2.mat'],'ucm2');
    %% 3. usage example
    %load double sized ucm
    load([seggpbDir im_name '.mat'],'ucm2');
    % convert ucm to the size of the original image
    ucm = ucm2(3:2:end, 3:2:end);
    % get the boundaries of segmentation at scale k in range [0 1]
    k = 0.02;
    bdry = (ucm >= k);
    % get superpixels at scale k without boundaries:
    labels2 = bwlabel(ucm2 <= k);
    seg = labels2(2:2:end, 2:2:end)-1;
    save([segbaseDir im_name '.mat'],'seg');
end
