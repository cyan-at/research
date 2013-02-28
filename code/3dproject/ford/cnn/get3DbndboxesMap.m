function [bndboxes] = get3DbndboxesMap(scanDir)
    addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/';
    clusterDir = strcat(scanDir,'clusters/');
    %compute mats for all pcds
    pcds = catalogue(clusterDir,'pcd');
    bndboxes = [];
    q = length(pcds);
    for j = 1:10
        pcdpath = cell2mat(pcds(j));
        disp(pcdpath);
        pc = pcd2mat(pcdpath);
        [bndbox cam] = extractBndbox(pc);
        bndboxes = [bndboxes; [bndbox,cam,j]];
    end
    %these are the bndboxes from segmentation
    [seg,idx] = drawResults(scanDir,bndboxes);
    segclr = repmat('r',1,size(seg,1));
    %these are the ground truths
    lbl = getLblBndboxes(scanDir);
    
    lblclr = repmat('g',1,size(lbl,1));
    imageName = strcat(scanDir,'/imageFull.ppm');
    I = imread(imageName);
    height = size(I,1)/5;
    width = size(I,2);
    if(height == 616)
        height = height*2;
        I = imresize(I, [height*5 width]);
    end
    I_rotated = imrotate(I, -90);
    I_rotated = flipdim(I_rotated,2);
    total = cat(1,num2cell(seg,2),num2cell(lbl,2));
    clr = [segclr,lblclr];
    showboxes_color(I_rotated,total,clr);
end