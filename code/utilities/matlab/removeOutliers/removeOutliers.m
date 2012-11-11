%11/10/12
clc;
targetDir = '/home/charlie/Desktop/research/data/segmentation/';
targetHasCar = strcat(targetDir,'hascar/%s');
targetNoCar = strcat(targetDir, 'nocar/%s');
labels = catalogue(label_dir, 'txt');
label_dir = fullfile(root_dir,[data_set '/label_' num2str(cam)]);
for i = 1:size(labels,2);