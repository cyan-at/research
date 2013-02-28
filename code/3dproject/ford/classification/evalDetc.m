%go through every scene, and for each scene grab the labl bnding boxes
%grab the detection results from every scene and for every cam in hand
%labels, get the corresponding detection bndboxes

%load the param file
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);

researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');

root = trainRoot;
fs = catalogue(root,'folder');
totalClusters = 0;
total = 0;
found = 0;
for i = 1:length(fs)
    disp(i);
    scanFolder = strcat(root,cell2mat(fs(i))); disp(scanFolder);
    pcdDir = strcat(scanFolder,'/classified/pcd/');
    results = collectDetectionResults(pcdDir);
    %filter out by cam ones
    handlabels = getLblBndboxes(scanFolder);
    [ lbls, overlaps, t, f, tc] = getOverlaps(scanFolder,results,PARAM);
    totalClusters = totalClusters + tc; total = total + t; found = found + f;
    disp(totalClusters);
    disp(total);
    disp(found);
end
rFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/detectionResults.txt';
fid = fopen(rFile,'w');
fprintf(fid,'total clusters evaluated: %d\n', totalClusters);
fprintf(fid,'total ground truths: %d\n', total);
fprintf(fid,'total ground truths detected: %d\n',found);
fprintf(fid,'accuracy: %d\n',found/total);
fclose(fid);

