researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
siSource = '/mnt/neocortex/scratch/jumpbot/data/3dproject/fordsource/';
if (~exist(siSource,'dir')); mkdir(siSource); end;
siTrain = strcat(siSource,'train/');
if (~exist(siTrain,'dir')); mkdir(siTrain); end;
siTest = strcat(siSource,'test/');
if (~exist(siTest,'dir')); mkdir(siTest); end;
siTrainCar = strcat(siTrain,'car/');
if (~exist(siTrainCar,'dir')); mkdir(siTrainCar); end;
siTrainNot = strcat(siTrain,'not/');
if (~exist(siTrainNot,'dir')); mkdir(siTrainNot); end;
siTestCar = strcat(siTest,'car/');
if (~exist(siTestCar,'dir')); mkdir(siTestCar); end;
siTestNot = strcat(siTest,'not/');
if (~exist(siTestNot,'dir')); mkdir(siTestNot); end;

trainRoot = strcat(scanFolderRoot,'train/');
testRoot  = strcat(scanFolderRoot,'test/');

trains = catalogue(trainRoot,'folder');
for i = 1:length(trains)
    %these are folders, for each folder, for every cluster, compute the
    %bndboxes and 
    scanFolder = cell2mat(trains(i));
    scanDir = strcat(trainRoot,scanFolder,'/');
    clusterDir = strcat(scanDir,'clusters/');
    carsDir = strcat(scanDir,'cars/');
    if (~exist(carsDir,'dir')); mkdir(carsDir); end;
    notsDir = strcat(scanDir,'nots/');
    if (~exist(notsDir,'dir')); mkdir(notsDir); end;
    %compute mats for all pcds
    pcds = catalogue(clusterDir,'pcd');
    bndboxes = [];
    q = length(pcds);
    for j = 1:5
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
    
    carsFound = 0;
    notsFound = 0;
    numNots = 5;
    threshold = 0.5;
    %find over laps
    %create the amp file
    mapFile = strcat(clusterDir,'map.txt');
    fid = fopen(mapFile,'w');
    for segi = 1:size(seg,1)
%         overlap = boxoverlap(lbl,seg(segi,:));
%         if (max(overlap) > threshold)
%             %get the car
%             carcluster = pcds(idx(segi));
%             pcdpath = cell2mat(carcluster);
%             [x,y,z] = fileparts(pcdpath);
%             targetpath = fullfile(siTrainCar,strcat(scanFolder,'_',y,'.mat'));
%             pc = pcd2mat(pcdpath);
%             save(targetpath,'pc');
%             carsFound = carsFound + 1;
%         elseif max(overlap <= 0.15)
%             if (notsFound <= numNots)
%                 notcluster = pcds(idx(segi));
%                 pcdpath = cell2mat(notcluster);
%                 [x,y,z] = fileparts(pcdpath);
%                 targetpath = fullfile(siTrainNot,strcat(scanFolder,'_',y,'.mat'));
%                 pc = pcd2mat(pcdpath);
%                 save(targetpath,'pc');
%                 notsFound = notsFound + 1;
%             end
%         end
        %write the bndbox to text file
        fprintf(fid,'%s %s\n',seg(segi,:),cell2mat(pcds(idx(segi)))); 
    end
    fclose(fid);
end