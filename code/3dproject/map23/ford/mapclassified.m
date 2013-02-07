researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/FordScans/';
addpath(genpath(strcat(researchPath,'/library/')));
scans = catalogue(scanFolderRoot,'folder');
q = length(scans);
for i = 1:q
    %these are folders, for each folder, get the classified directory, and
    %close all;
    
    %find all of the pcs labeled cars
    scanFolder = cell2mat(scans(i));
    %disp(scanFolder);
    classifiedDir = strcat(scanFolderRoot,scanFolder,'/classified/mat/'); 
    if (~exist(classifiedDir,'dir')); 
        continue;
    end;
    cars = catalogue(classifiedDir,'mat', 'car_');
    %construct bndboxes, an array of rows where each row is [bounds cam]
    disp('finding bounding boxes');
    bndboxes = [];
    for carmat = 1:length(cars)
        %disp(cell2mat(cars(carmat)));
        [bndbox cam] = readClusterAndMap(cell2mat(cars(carmat)));
        bndboxes = [bndboxes; [bndbox,cam]];
    end
    %draw results
    detectionimage = strcat(scanFolderRoot,scanFolder,'/detection.png');
    bndboxesFull = drawResults(strcat(scanFolderRoot,scanFolder),bndboxes,detectionimage);
    save(strcat(scanFolderRoot,scanFolder,'/bndboxes.mat'),'bndboxes');
    save(strcat(scanFolderRoot,scanFolder,'/bndboxesFull.mat'),'bndboxesFull');
    %wait for user feedback, or save the image or construct matrix for CNN
    %waitforbuttonpress;
end