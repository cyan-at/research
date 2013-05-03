function [neg_scores,pos_scores] = gatherTestData(interv)
%expects the rbf_model_name under pwd/rbf_test/
%opt standardize is true for statistical normalization
close all;
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

%load 2D things
encoder2D = load('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/hog_kmeans_tri_pyr3_h2048_imgW16_minN10_r2/results/hog/encoder.mat');
model2D = load('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/hog_kmeans_tri_pyr3_h2048_imgW16_minN10_r2/svm/hog/model.mat');
encoder2D = encoder2D.encoder;
model2D = model2D.model;
hogparam = loadParameters('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/', '1_pyr3_hidden2048_ps16_gs2_imgW16_minN10_r2.txt');

%load 3D model, encoder and parameters
source3D = 'si_kmeans_tri_pyr3_h2048_imgW16_minN10_r2_imgperclass80_plus';
model3D = load(sprintf('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/%s/svm/si/model.mat',source3D));
encoder3D = load(sprintf('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/%s/results/si/encoder.mat',source3D));
encoder3D = encoder3D.encoder;
model3D = model3D.model;
siparam = loadParameters('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/', '1_pyr3_hidden2048_ps16_gs2_imgW16_minN10_r2.txt');

target_dir = sprintf('%s/test_plus_interv%d',pwd,interv);
ensure(target_dir);

pos_scores_cnn = [];
pos_scores_3D = [];
pos_scores_2D = [];

neg_scores_cnn = [];
neg_scores_3D = [];
neg_scores_2D = [];

for j=1:interv:length(d)
    fprintf('%d left\n',length(d)-j);
    scoresFile = sprintf('%s/scores/score_for_%s.mat',pwd,d(j).name);
    framenum = sscanf(d(j).name,'data_batch_%d_res.txt');
    dashIdx = findstr(mapTo{framenum},'-');
    % load gt and img
    scene = mapTo{framenum}(1:dashIdx-1);
    cam = mapTo{framenum}(dashIdx+1:end);
    load(sprintf('%s/%s/%s.mat',root_mat,scene,cam));
    gt(j) = obj_to_gt(obj);
    if (exist(scoresFile,'file'))
        load(scoresFile);
        bbox = s.bbox;
        two_scores = s.two_scores;
        cnn_scores = s.cnn_scores;
        three_scores = s.three_scores;
    else
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
        scene = mapTo{framenum}(1:dashIdx-1);
        cam = mapTo{framenum}(dashIdx+1:end);
        load(sprintf('%s/%s/%s.mat',root_mat,scene,cam));
        gt(j) = obj_to_gt(obj);
        
        % set thresh to .5
        bbox = bbox(bbox(:,5)>.5,:);
        idx=nms(bbox,.5);  % apply nms
        bbox = bbox(idx,:);
        
        %load the 3D data
        three_cam = sprintf('%s/%s/three_%s.mat',root_mat,scene,cam);
        load(three_cam); %data
        [three_flags,three_scores] = cnn_get3Dscores_plus(data,bbox,encoder3D,model3D,siparam);
        %get 2D data
        [two_scores] = cnn_get2Dscores_plus(img,bbox,encoder2D,model2D,hogparam);
        valid = find(three_flags==0);
        two_scores = two_scores(valid,:);
        bbox = bbox(valid,:);
        three_scores = three_scores(valid,:);
        cnn_scores = bbox(:,5);
        %save the scores
        s = struct();
        s.bbox = bbox;
        s.two_scores = two_scores;
        s.cnn_scores = cnn_scores;
        s.three_scores = three_scores;
        save(scoresFile,'s');
    end
    
    posi = [];
    negi = [];
    %compute overlap with ground truth
    for i = 1:size(bbox,1)
        o = boxoverlap(gt(j).BB, bbox(i,:));
        if (max(o) > 0.4)
            posi = [posi, i];
        else
            negi = [negi, i];
        end
    end
    pos_cnn_scores = cnn_scores(posi);
    neg_cnn_scores = cnn_scores(negi);
    
    pos_hog_scores = two_scores(posi);
    neg_hog_scores = two_scores(negi);
    
    %update
    pos_scores_cnn =[pos_scores_cnn; cnn_scores(posi)];
    pos_scores_3D = [pos_scores_3D; three_scores(posi)];
    pos_scores_2D = [pos_scores_2D; two_scores(posi)];
    neg_scores_cnn = [neg_scores_cnn;cnn_scores(negi)];
    neg_scores_3D = [neg_scores_3D;three_scores(negi)];
    neg_scores_2D = [neg_scores_2D;two_scores(negi)];
end

%save things
neg_scores = struct();
neg_scores.cnn = neg_scores_cnn;
neg_scores.two = neg_scores_2D;
neg_scores.three = neg_scores_3D;
neg_matrix = [neg_scores_cnn,neg_scores_2D,neg_scores_3D];
neg_matrix = neg_matrix';
neg_scores.matrix = neg_matrix;

pos_scores = struct();
pos_scores.cnn = pos_scores_cnn;
pos_scores.two = pos_scores_2D;
pos_scores.three = pos_scores_3D;
pos_matrix = [pos_scores_cnn,pos_scores_2D,pos_scores_3D];
pos_matrix = pos_matrix';
pos_scores.matrix = pos_matrix;

neg_target = sprintf('%s/neg_scores.mat',target_dir);
pos_target = sprintf('%s/pos_scores.mat',target_dir);
save(neg_target,'neg_scores');
fprintf('Negatives: %s\n',neg_target);
save(pos_target,'pos_scores');
fprintf('Positives: %s\n',pos_target);

end