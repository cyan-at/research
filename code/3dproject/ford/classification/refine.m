%go through every scene, and for each scene grab the labl bnding boxes
%grab the detection results from every scene and for every cam in hand
%labels, get the corresponding detection bndboxes

researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');

%load the param file
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);

res_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch/results_afternms/';
%get the map file
fid = fopen(strcat(res_dir,'map.txt'),'r');
map = textscan(fid,'%d %s', 'Delimiter', ' ');
idx = map{1}; scene = map{2};
fclose(fid);
results = catalogue(res_dir,'txt','data');

root = testRoot;
fs = catalogue(root,'folder');
totalClusters = 0;
total = 0;
found = 0;
for i = 9:length(fs)
    disp(i);
    scanFolder = strcat(root,cell2mat(fs(i))); disp(scanFolder);
    pcdDir = strcat(scanFolder,'/classified/pcd/');
    %attempt to get the cnn detections for this scene
    [cnnDetections] = grabCNN(idx, scene, res_dir, cell2mat(fs(i)));
    results = collectDetectionResults(pcdDir);
    %get overlaps with ground truths
    [newDetections] = overlapCNN(scanFolder,results,PARAM, cnnDetections);
    
end