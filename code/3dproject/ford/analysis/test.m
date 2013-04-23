researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath /mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/cnn/
addpath /mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/utils

res_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train_working_folder/results_beforenms_redo_train_ver2';
mode = 'baseline';

root_mat = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test';
d = dir(fullfile(res_dir,'/*_res.txt'));

[~, mapTo] = textread(fullfile(res_dir,'map.txt'), '%d %s');
load('/mnt/neocortex/data/Ford/IJRR-Dataset-1-subset/PARAM.mat');
load('/mnt/neocortex/scratch/norrathe/tmp/pascal_ford/results3/data_final.mat');

%load 2D things
encoder2D = load('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/hog_kmeans_tri_pyr3_h2048_imgW16_minN10_r2/results/hog/encoder.mat');
model2D = load('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/hog_kmeans_tri_pyr3_h2048_imgW16_minN10_r2/svm/hog/model.mat');
encoder2D = encoder2D.encoder;
model2D = model2D.model;

% load model, encoder and parameters
model3D = load('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/si_kmeans_tri_pyr3_h2048_imgW16_minN10_r2_2/svm/si/model.mat');
encoder3D = load('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/si_kmeans_tri_pyr3_h2048_imgW16_minN10_r2_2/results/si/encoder.mat');
encoder3D = encoder3D.encoder;
model3D = model3D.model;

% for CNN scores of proposal 
for j=1:length(d)
    [filename, score, ~] = textread(fullfile(res_dir,d(j).name),'%s %f %d');
    if isempty(filename)
        continue;
    end
    framenum = sscanf(d(j).name,'data_batch_%d_res.txt');
    bbox = [];
    for i=1:length(filename)
        bb = sscanf(filename{i},'%d_%d_%d_%d');
        bb = bb';
        bb = [bb score(i)];
        bbox = [bbox; bb];
    end
    
    dashIdx = findstr(mapTo{framenum},'-');
    % load gt and img
    load(sprintf('%s/%s/%s.mat',root_mat,mapTo{framenum}(1:dashIdx-1),mapTo{framenum}(dashIdx+1:end)));
    gt(j) = obj_to_gt(obj);
    
    % set thresh to .5
    bbox = bbox(bbox(:,5)>.5,:);

    old_bbox = bbox;
    idx=nms(old_bbox,.5);
    old_bbox = old_bbox(idx,:);

    idx=nms(bbox,.5);  % apply nms
    
    bbox = bbox(idx,:);
    
    pred_bbox{j} = bbox;
    [m, acc] = eval_cnn(pred_bbox,gt,.5,'ap');
    fprintf('ap: %4.4f\n',m.ap);
end
