function gather_data()
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
hogparam = loadParameters('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/', '1_pyr3_hidden2048_ps16_gs2_imgW16_minN10_r2.txt');

%load 3D model, encoder and parameters
source3D = 'si_kmeans_tri_pyr3_h2048_imgW16_minN10_r2_imgperclass80_plus';
model3D = load(sprintf('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/%s/svm/si/model.mat',source3D));
encoder3D = load(sprintf('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/%s/results/si/encoder.mat',source3D));
encoder3D = encoder3D.encoder;
model3D = model3D.model;
siparam = loadParameters('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/new3D/', '1_pyr3_hidden2048_ps16_gs2_imgW16_minN10_r2.txt');

%load RBF model
suffix = 'run_80_pos1_neg2_xCNN_y3D';
rbf_location = sprintf('/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/analysis/%s/%s/model.mat',...
    source3D,suffix);
rbfmodel = load(rbf_location);
rbfmodel = rbfmodel.model;

pos_three = [];
pos_cnn = [];
pos_two = [];

neg_three = [];
neg_cnn = [];
neg_two = [];

for j=1:5:length(d)
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
        
        old_bbox = bbox;
        idx=nms(old_bbox,.5);
        old_bbox = old_bbox(idx,:);
        
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
    
    %split data
    [posIdx, negIdx] = splitDataPosNeg(bbox,gt(j),0.5);
    
    pos_three = [pos_three,three_scores(posIdx)'];
    neg_three = [neg_three,three_scores(negIdx)'];
    
    pos_cnn = [pos_cnn,cnn_scores(posIdx)'];
    neg_cnn = [neg_cnn,cnn_scores(negIdx)'];
    
    pos_two = [pos_two,two_scores(posIdx)'];
    neg_two = [neg_two,two_scores(negIdx)'];    
end

%save data
%save things
neg_scores = struct();
neg_scores.cnn = neg_cnn;
neg_scores.two = neg_two;
neg_scores.three = neg_three;
neg_matrix = [neg_cnn;neg_two;neg_three];
neg_scores.matrix = neg_matrix;

pos_scores = struct();
pos_scores.cnn = pos_cnn;
pos_scores.two = pos_two;
pos_scores.three = pos_three;
pos_matrix = [pos_cnn;pos_two;pos_three];
pos_scores.matrix = pos_matrix;

suffix = 'test_skip5';
neg_target = sprintf('%s/neg_scores_%s.mat',pwd, suffix);
pos_target = sprintf('%s/pos_scores_%s.mat',pwd, suffix);
save(neg_target,'neg_scores');
save(pos_target,'pos_scores');
end