function result = just_cnn(interval)
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath /mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/cnn/
addpath /mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/utils

%get the cnn detections
res_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train_working_folder/results_beforenms_redo_train_ver2';
root_mat = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test';
d = dir(fullfile(res_dir,'/*_res.txt'));
[~, mapTo] = textread(fullfile(res_dir,'map.txt'), '%d %s');
load('/mnt/neocortex/data/Ford/IJRR-Dataset-1-subset/PARAM.mat');

%load 3D model, encoder and parameters
source3D = 'si_kmeans_tri_pyr3_h2048_imgW16_minN10_r2_imgperclass80_plus';
model3D = load(sprintf('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/%s/svm/si/model.mat',source3D));
encoder3D = load(sprintf('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/%s/results/si/encoder.mat',source3D));
encoder3D = encoder3D.encoder;
model3D = model3D.model;
siparam = loadParameters('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/', '1_pyr3_hidden2048_ps16_gs2_imgW16_minN10_r2.txt');

% for CNN scores of proposal 
for j=1+interval:interval:length(d)
    [filename, score, ~] = textread(fullfile(res_dir,d(j).name),'%s %f %d');
    if isempty(filename); continue; end;
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
    dashIdx = findstr(mapTo{framenum},'-');
    % load gt and img
    scene = mapTo{framenum}(1:dashIdx-1);
    cam = mapTo{framenum}(dashIdx+1:end);
    three_cam = sprintf('%s/%s/three_%s.mat',root_mat,scene,cam);
    load(three_cam); %data, identify unique clusters and add them as seeds
    
    bbox = bbox(bbox(:,5)>.5,:);
    [three_flags,three_scores] = cnn_get3Dscores_plus(data,bbox,encoder3D,model3D,siparam);
    %get 2D data
    [two_scores] = cnn_get2Dscores_plus(img,bbox,encoder2D,model2D,hogparam);
    valid = find(three_flags==0);
    two_scores = two_scores(valid,:);
    bbox = bbox(valid,:);
    three_scores = three_scores(valid,:);
    bbox(:,5) = three_scores;
    idx=nms(bbox,.5);  % apply nms
    bbox = bbox(idx,:);
    pred_bbox{j} = bbox;
    [m, ~] = eval_cnn(pred_bbox,gt,.5,'ap');
    fprintf('ap: %4.4f\n',m.ap);
end
result = m;
