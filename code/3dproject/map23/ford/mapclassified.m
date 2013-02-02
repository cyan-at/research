researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
addpath(genpath(strcat(researchPath,'/library/')));
scans = catalogue(scanFolderRoot,'folder');
q = length(scans);
for i = 1:1
    %these are folders, for each folder, get the classified directory, and
    %find all of the pcs labeled cars
    scanFolder = cell2mat(scans(i));
    disp(scanFolder);
    classifiedDir = strcat(scanFolderRoot,scanFolder,'/classified/mat/'); 
    if (~exist(classifiedDir,'dir')); 
        continue;
    end;
    cars = catalogue(classifiedDir,'mat', 'car_');
    bndboxes = [];
    disp('finding bounding boxes');
    %bndboxes is a n x 4 matrix of bndboxes
    for j = 1:1
        [bndbox cam] = readClusterAndMap(cell2mat(cars(j)));
        if (isempty(bndbox)); continue; end;
        %add bndbox to a list of bndboxes;
        bndboxes = [bndboxes; bndbox];
    end
    %display your results
    uniquecam = unique(cam);
    close all;
    for i = 1:1
        figure;
        c = uniquecam(i);
        im_name = strcat(scanFolderRoot,scanFolder,'/image',num2str(c-1),'.ppm');
        I = imread(im_name);
        I = imresize(I, [1232,1616]);
        I_rotated = imrotate(I, -90);
        I_rotated = flipdim(I_rotated,2);
        %draw bounding boxs on pixel
        for j = 1:1
            bboxes{j} = bndboxes(j,:);
        end
        showboxes_color(I_rotated, bboxes, 'b');
        waitforbuttonpress;
    end
end