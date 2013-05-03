function result = just_2D(interv)
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
    bbox(:,5) = two_scores;
    idx=nms(bbox,.5);  % apply nms
    bbox = bbox(idx,:);
    %saveboxes(img,bbox,[],'');
    pred_bbox{j} = bbox;
    [m, ~] = eval_cnn(pred_bbox,gt,.5,'ap');
    fprintf('ap: %4.4f\n',m.ap);    
end


result = m;
