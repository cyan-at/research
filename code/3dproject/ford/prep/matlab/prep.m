%generates the withlabels directory
addpath(genpath('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/'));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/correct/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
ensure(targetRoot); ensure(trainRoot); ensure(testRoot);
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
    idx = cell2mat(haslabels(i));
    [x,y,~] = fileparts(idx);
    %get the image number
    %create the working directory
    if (trainCollected < 120)
        workingPath = strcat(targetRoot,'train/',y,'/');
        mode = 1;
    else
        workingPath = strcat(targetRoot,'test/',y,'/');
        mode = 2;
    end
    %first do a check for scan and images
    z = strsplit(y,'obj');
    z = cell2mat(z(2));
    scan = strcat(dataSource, 'SCANS/Scan',z,'.mat');
    if (~exist(scan,'file'))
        continue;
    end
    %if pass the test
    ensure(workingPath);
    
    %find the scan file and copy it over
    scan = strcat(dataSource, 'SCANS/Scan',z,'.mat');
    targetScanFile = strcat(workingPath, 'scan.mat');
    cpCmd = sprintf('cp %s %s', scan, targetScanFile);
    system(cpCmd);
    %find all mats for the given image
    idx2 = catalogue(labelDir2,'mat',y);
    for j = 1:length(idx2)
        a = cell2mat(idx2(j));
        cam = strsplit(a,'offset');
        suffix = cell2mat(cam(2));
        targetLabelFile = strcat(workingPath,'cam',suffix(1),'.mat');
        cpCmd = sprintf('cp %s %s', a, targetLabelFile);
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