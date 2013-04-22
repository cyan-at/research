%exhaustive search
%import
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath(genpath('./models/'));
rmpath('/usr/local/MATLAB/R2012a/toolbox/ident/ident');
addpath(genpath('./svmlinear/'));
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/
addpath /mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/

%parameters
sceneRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(sceneRoot,'train/');
testRoot = strcat(sceneRoot,'test/');
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);
% beforeNMSdir = '/mnt/neocortex/scratch/norrathe/data/car_patches/multiple_filters/batch/test_results/';
beforeNMSdir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train/results_afternms_redo_train_ver2/';
outputdir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/refine_3_20_13_2/';
ensure(outputdir);

%load some classifier stuff
classifier2D = struct(); 
classifier3D = struct();
clear encoder; load ('hogencoder.mat');
classifier2D.encoder = encoder;
clear model; load ('hogmodel.mat');
classifier2D.model = model;
clear encoder; load ('siencoder.mat');
classifier3D.encoder = encoder;
clear model; load ('simodel.mat');
classifier3D.model = model;
parameters = loadParameters('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/refinement/models/');

%get the map file
fid = fopen(strcat(beforeNMSdir,'map.txt'),'r');
map = textscan(fid,'%d %s', 'Delimiter', ' ');
idx = map{1}; scene = map{2};
fclose(fid);

root = testRoot;
fs = catalogue(root,'folder');
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    %for every scene, get the cnn detections for this scene
    cnnDetections = grabCNN(idx, scene, beforeNMSdir, cell2mat(fs(i)));
    [newDetections results] = refine(workingPath,cnnDetections,classifier2D,classifier3D,parameters);
    %write the new detections into data_batch files
    c = strmatch(cell2mat(fs(i)),scene);
    y = idx(c);
    if ~isempty(y)
        for j = 1:length(y)
            cam = strsplit(cell2mat(scene(y(j))),'cam'); cam = cell2mat(cam(2)); cam = str2num(cam);
            det = find(newDetections(:,5)==cam);
            dataFile = strcat(outputdir,'data_batch_',num2str(y(j)),'_res.txt');
            fid = fopen(dataFile,'w');
            for z = 1:length(det)
                jpgString = sprintf('%d_%d_%d_%d.jpg %f\n',[round(newDetections(det(z),1:4)),newDetections(det(z),6)]);
                fprintf(fid,jpgString);
            end
            fclose(fid);
        end
    end
end

%copy over map file
mfile = strcat(beforeNMSdir,'map.txt');
cpCmd = sprintf('cp %s %s', mfile, strcat(outputdir,'map.txt'));
system(cpCmd);
