%imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%some parameters
dataSource = '/mnt/neocortex/scratch/norrathe/IJRR-Dataset-1/IMAGES/FULL/';
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');

root = trainRoot;
fs = catalogue(root,'folder');
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    %for every workingpath, get the scan.mat file
    clear SCAN; load(strcat(workingPath,'/scan.mat'));
    temp = sprintf('%04.0f',SCAN.image_index);
    source = strcat(dataSource,'image',temp,'.ppm');
    destination = strcat(workingPath,'/imageFull.ppm');
    system(sprintf('cp %s %s', source, destination));
end

root = testRoot;
fs = catalogue(root,'folder');
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    %for every workingpath, get the scan.mat file
    clear SCAN; load(strcat(workingPath,'/scan.mat'));
    temp = sprintf('%04.0f',SCAN.image_index);
    source = strcat(dataSource,'image',temp,'.ppm');
    destination = strcat(workingPath,'/imageFull.ppm');
    system(sprintf('cp %s %s', source, destination));
end