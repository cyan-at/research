%11/10/12
clc;

root_dir = '/home/charlie/Desktop/extractExperiment/data/';
data_set = 'training';
data_set_target = '10_27_12';

targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/%s');
targetNoCar = strcat(targetDir, 'nocar/%s');
% get sub-directories
cam = 2; % 2 = left color camera
image_dir = fullfile(root_dir,[data_set '/image_' num2str(cam)]);
label_dir = fullfile(root_dir,[data_set '/label_' num2str(cam)]);
calib_dir = fullfile(root_dir,[data_set '/calib']);
%disp(label_dir);
%mapping stuff
mapping_dir = fullfile(root_dir, [data_set, '/mapping']);
mapping_file = sprintf('%s/train_mapping.txt',mapping_dir);
mapping_idx = sprintf('%s/train_rand.txt',mapping_dir);
if ~exist('map','var') readMap(mapping_idx, mapping_file); end;
labels = catalogue(label_dir, 'txt');
for i = 1:size(labels,2);
    [x y z] = fileparts(cell2mat(labels(i)));
    img_idx = str2num(y);
    % img_idx = labels(i);
    % load projection matrix
    % P = readCalibration(calib_dir,img_idx,cam);
    % load labels
    objects = readLabels(label_dir,img_idx);
    objectFile = sprintf('%s/%06d.txt',label_dir,img_idx);
    % load the point clouds
    pcFile = sprintf('/home/charlie/Desktop/extractExperiment/data/training/raw_data/%s/velodyne_points/data/%s.bin', map{i}{2}, map{i}{3});
    if (hascar(objects))
        pcdDirectory = sprintf(targetHasCar, map{i}{3});
    else
        pcdDirectory = sprintf(targetNoCar, map{i}{3});        
    end
    disp(pcdDirectory);
    if ~exist(pcdDirectory,'dir') mkdir(pcdDirectory); end;
    pcdFile = strcat(pcdDirectory,'/source.pcd');
    targetPCD = strcat(pcdDirectory,'/',sprintf('%06d.pcd',img_idx));
    mvCMD = sprintf('mv %s %s',pcdFile,targetPCD);
    system(mvCMD);
end
disp('Done');
