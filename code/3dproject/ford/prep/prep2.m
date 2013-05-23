%this code will run through the ford data set and copy things into working
%folders for DON, 3D segmentation, 2D segmentation, CNN, etc.
%all pointclouds
addpath(genpath('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/'));

targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
if (~exist(targetRoot,'dir')); mkdir(targetRoot); end;

dataSource = '/mnt/neocortex/scratch/norrathe/IJRR-Dataset-1/';

labelDir = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment1/mat/all/';
labelDir2 = '/mnt/neocortex/scratch/norrathe/data/experiment1/mat/resize_split_all/';
haslabels = catalogue(labelDir,'mat');

trainCollected = 0;
trainFile = strcat(targetRoot,'train.txt');
fidtrain = fopen(trainFile,'w');
testCollected = 0;
testFile = strcat(targetRoot,'test.txt');
fidtest = fopen(testFile,'w');

for i = 1:length(haslabels)
    disp(i);disp(trainCollected);disp(testCollected);
    idx = cell2mat(haslabels(i));
    [x,y,~] = fileparts(idx);
    %get the image number
    %create the working directory
    if (trainCollected < 120)
        scanDir = strcat(targetRoot,'train/',y,'/');
        mode = 1;
    else
        scanDir = strcat(targetRoot,'test/',y,'/');
        mode = 2;
    end
    %first do a check for scan and images
    z = strsplit(y,'obj');
    z = cell2mat(z(2));
    scan = strcat(dataSource, 'SCANS/Scan',z,'.mat');
    cam0 = strcat(dataSource, 'IMAGES/Cam0/image',z,'.ppm');
    if (~exist(scan,'file') || ~exist(cam0,'file'))
        continue;
    end
    %if pass the test
    if (~exist(scanDir,'dir')); mkdir(scanDir); end;
    
    %find the scan file and copy it over
    scan = strcat(dataSource, 'SCANS/Scan',z,'.mat');
    targetScanFile = strcat(scanDir, 'scan.mat');
    cpCmd = sprintf('cp %s %s', scan, targetScanFile);
    system(cpCmd);
    
    %find the images per camera, and the full image
    z = strsplit(y,'obj');
    z = cell2mat(z(2));
    cam0 = strcat(dataSource, 'IMAGES/Cam0/image',z,'.ppm');
    cam1 = strcat(dataSource, 'IMAGES/Cam1/image',z,'.ppm');
    cam2 = strcat(dataSource, 'IMAGES/Cam2/image',z,'.ppm');
    cam3 = strcat(dataSource, 'IMAGES/Cam3/image',z,'.ppm');
    cam4 = strcat(dataSource, 'IMAGES/Cam4/image',z,'.ppm');
    full = strcat(dataSource, 'IMAGES/FULL/image',z,'.ppm');
    targetImgName0 = strcat(scanDir, 'image0.ppm');
	cpCmd = sprintf('cp %s %s', cam0, targetImgName0);
    system(cpCmd);	
    targetImgName1 = strcat(scanDir, 'image1.ppm');
	cpCmd = sprintf('cp %s %s', cam1, targetImgName1);    
    system(cpCmd);
    targetImgName2 = strcat(scanDir, 'image2.ppm');
	cpCmd = sprintf('cp %s %s', cam2, targetImgName2);
    system(cpCmd);	
    targetImgName3 = strcat(scanDir, 'image3.ppm');
	cpCmd = sprintf('cp %s %s', cam3, targetImgName3);
    system(cpCmd);
    targetImgName4 = strcat(scanDir, 'image4.ppm');
	cpCmd = sprintf('cp %s %s', cam4, targetImgName4);
    system(cpCmd);
    targetImgNameFull = strcat(scanDir, 'imageFull.ppm');
    cpCmd = sprintf('cp %s %s', full, targetImgNameFull);
    system(cpCmd);

    %find all mats for the given image
    idx2 = catalogue(labelDir2,'mat',y);
    for j = 1:length(idx2)
        a = cell2mat(idx2(j));
        cam = strsplit(a,'offset');
        suffix = cell2mat(cam(2));
        targetLabelFile = strcat(scanDir,'cam',suffix(1),'.mat');
        cpCmd = sprintf('cp %s %s', a, targetLabelFile);
        disp(cpCmd);
        system(cpCmd);
        
        %add to label file
        if (mode == 1)
            fprintf(fidtrain,'%s\n',targetLabelFile); 
        else
            fprintf(fidtest,'%s\n',targetLabelFile);
        end
    end
    
    if (mode == 1)
        trainCollected = trainCollected + 1;
    else
        testCollected = testCollected + 1;
    end
end
fclose(fidtrain);
fclose(fidtest);