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

res_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train_test/results_afternms_redo_train/';
output_dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/refineNew/';
if (~exist(output_dir,'dir')); mkdir(output_dir); end;
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
for i = 1:length(fs)
    %disp(i);
    scanFolder = strcat(root,cell2mat(fs(i))); disp(scanFolder);
    pcdDir = strcat(scanFolder,'/classified/pcd/');
    %attempt to get the cnn detections for this scene
    [cnnDetections] = grabCNN(idx, scene, res_dir, cell2mat(fs(i)));
    %resolve nested cnn detections
    
    results = collectDetectionResults(pcdDir);
    %get overlaps with ground truths
    [newDetections] = overlapCNN(scanFolder,results,PARAM, cnnDetections);
    %write the new detections into data_batch files
    c = strmatch(cell2mat(fs(i)),scene);
    y = idx(c);
    for j = 1:length(y)
        cam = strsplit(cell2mat(scene(y(j))),'cam'); cam = cell2mat(cam(2)); cam = str2num(cam);
        det = find(newDetections(:,5)==cam);
        dataFile = strcat(output_dir,'data_batch_',num2str(y(j)),'_res.txt');
        fid = fopen(dataFile,'w');
        for z = 1:length(det)
            jpgString = sprintf('%d_%d_%d_%d.jpg %f\n',[round(newDetections(det(z),1:4)),newDetections(det(z),6)]);
            fprintf(fid,jpgString);
        end
        fclose(fid);
    end
end
%copy over map file
mfile = strcat(res_dir,'map.txt');
cpCmd = sprintf('cp %s %s', mfile, strcat(output_dir,'map.txt'));
system(cpCmd);