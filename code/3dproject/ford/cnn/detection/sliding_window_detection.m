function sliding_window_detection(train_datadir,test_datadir,method,ps,gs,numHidden)

global Unsup pyramid meth codebookPath
addpath(genpath('../recognition'));
addpath ../utils/

if ~exist('train_datadir','var')
    train_datadir = '~/scratch/3dproject/data/experiments/experiment1/mat/train';
end
if ~exist('test_datadir','var')
    test_datadir = '~/scratch/3dproject/data/experiments/experiment1/mat/test';
end
if ~exist('save_datadir','var')
    save_datadir = '~/scratch/norrathe/data/detection/hog';
end
if ~exist('method','var')
    method = 'kmeans';
end
if ~exist('det_grid','var')
    det_grid = 10;
end
if ~exist('numHidden','var')
    numHidden = 128;
end

if ~exist('all_mat_dir','var'), all_mat_dir = '~/scratch/norrathe/data/experiment1/mat/resize_split_all_pos_neg'; end
if ~exist('train_img_dir','var'), train_img_dir = '~/scratch/norrathe/data/car_patches/sliding_windows'; end
if ~exist('train_feature_dir','var'), train_feature_dir = '~/scratch/norrathe/data/car_feature/sliding_windows/train'; end
if ~exist('ps','var'), ps = 8; gs = 6; end

meth = method;
pyramid = [1 2];
codebookPath = '~/scratch/norrathe/codebook/';
dataSet = extract_sift_from_mat(ps,gs,train_img_dir,all_mat_dir,train_feature_dir);
% dataSet = 'patch8_grid2_optresize0';
[Unsup fname_save] = cal_feat_unsup(ps,gs,dataSet,train_feature_dir);
%% Train SVM
[tr_fea, ~, tr_label] = get_features(fname_save,meth,pyramid,train_feature_dir,[],[],codebookPath,'nonlap');
svmmodel = train_svm('linear',tr_fea,tr_label,5,1);

%% Detection
database = makeDatabase_test_from_mat(fullfile(all_mat_dir,'car'),1,220);
thresh = linspace(1,.8,5);
svm = zeros(size(thresh));
dsum = zeros(size(thresh));
for i=1:length(thresh)
    [svm(i) dsum(i)] = run_sliding_windows(database,det_grid,ps,gs,svmmodel,thresh(i));
end

function [fea label] = load_features(save_datadir,dataSet,num)
d = dir(fullfile(save_datadir,dataSet));
d = d(3:end);
fea = zeros(num,2048);
label = [];
nume = 0;
c_label = 0;
for i=1:length(d)
    s = d(i).name;
    dd = dir(fullfile(save_datadir,dataSet,s));
    dd = dd(3:end);
    label = [label; ones(length(dd),1)*c_label];
    for j=1:length(dd)
        nume = nume+1;
       load(fullfile(save_datadir,dataSet,s,dd(j).name));
       fea(nume,:) = feaArr;
    end
    c_label = c_label+1;
end

function [dataSet num] = hogExt(datapath,save_datadir,resize,bin)

dataSet = sprintf('bin%d',bin);
d = dir(datapath);
d = d(3:end);
save_datadir = fullfile(save_datadir,dataSet);
if ~isdir(save_datadir)
    mkdir(save_datadir);
end
num = 0;
for i=1:length(d)
    subname = d(i).name;
    if ~isdir(fullfile(save_datadir,subname))
        mkdir(fullfile(save_datadir,subname));
    end
    ddir = dir(fullfile(datapath,subname));
    ddir = ddir(3:end);
    for j=1:length(ddir)
        sub = ddir(j).name;
        clear obj img;
        
        fprintf('Processing HOG: %s\n',sub)
        if ~strcmp(subname,'car')
            load(fullfile(datapath,subname,sub),'img','nonlap_neg_obj');
            obj = nonlap_neg_obj;
        else
            load(fullfile(datapath,subname,sub));
        end
        for k=1:length(obj)
            if isfield(obj(k),'difficult') & obj(k).difficult
                continue;
            end
            num = num+1;
            bbox = obj(k).bndbox;
            I = imresize(img(bbox(2):bbox(4),bbox(1):bbox(3),:), resize);
            feaArr = features(double(I), bin);
            feaArr = single(feaArr(:));
            save(fullfile(save_datadir,subname,sprintf('%.4d',num)),'feaArr');
        end
    end
        
end

    fprintf('\n');

function [svm_info dsum_info] = run_sliding_windows(database,stride,ps,gs,svmmodel,thresh)
global Unsup pyramid meth numHidden
total_dets = 0;
correct_dets = 0;
num_instances = 0;
start_ps = 30;
max_ps = 150;
save_svmpath = '/mnt/neocortex/scratch/norrathe/data/car_detected_patches/sliding_windows/svm_pred';
save_dsumpath = sprintf('/mnt/neocortex/scratch/norrathe/data/car_detected_patches/sliding_windows/direct_sum_thresh%g',thresh);
if ~isdir(save_svmpath)
    mkdir(save_svmpath);
end
if ~isdir(save_dsumpath)
    mkdir(save_dsumpath);
end
% [n_det n_pos n_correct precision recall]
svm_info = [0 0 0 0 0];
dsum_info = [0 0 0 0 0];

for i=2:database.nframe
    load(database.path{i});
    
    all_bbox_svm = [];
    all_bbox_dsum = [];
    for j=1:length(obj)
        obj(j).bndbox(2) = obj(j).bndbox(2)-floor(size(img,1)/3);
        obj(j).bndbox(4) = obj(j).bndbox(4)-floor(size(img,1)/3);
    end
    img = img(floor(size(img,1)/3):size(img,1),:,:);
    tic
    for j=start_ps:20:max_ps
        feat = sift(img,ps,gs);
        [im_h, im_w, ~] = size(img);
        
        % get SIFT grid
        remX = mod(im_w-ps/2,gs);
        offsetX = floor(remX/2)+1;
        remY = mod(im_h-ps/2,gs);
        offsetY = floor(remY/2)+1;
        [gridX,gridY] = meshgrid(offsetX+ps/2:gs:im_w-ps/2+1, offsetY+ps/2:gs:im_h-ps/2+1);
        gridX = gridX(:);
        gridY = gridY(:);
        
        % get sliding window grid
        frame_remX = mod(im_w-j/2,stride);
        frame_remY = mod(im_h-j/2,stride);
        frame_offX = floor(frame_remX/2)+1;
        frame_offY = floor(frame_remY/2)+1;
        [f_gx f_gy] = meshgrid(frame_offX+j/2:stride:im_w-j/2+1, frame_offY+j/2:stride:im_h-j/2+1);
        f_gx = f_gx(:);
        f_gy = f_gy(:);
        
        % iterate all sliding windows
        pool = zeros(length(f_gx),numHidden*sum(pyramid.^2));
        bndbox = zeros(length(f_gx),4);
        for k=1:length(f_gx)
            fprintf('[%d/%d]\n',k,length(f_gx));
            x_lo = f_gx(k) - (j - ceil(j/2));
            x_hi = f_gx(k) + ceil(j/2) - 1;
            y_lo = f_gy(k) - (j - ceil(j/2));
            y_hi = f_gy(k) + ceil(j/2) - 1;
            idx = find(x_lo<gridX & x_hi>gridX & y_lo<gridY & y_hi>gridY);
            patch_feat.feaArr = feat.feaArr(:,idx);
            patch_feat.width = j;
            patch_feat.height = j;
            patch_feat.x = gridX(idx);
            patch_feat.y = gridY(idx);
            patch_feat.x = patch_feat.x-min(patch_feat.x)+1;
            patch_feat.y = patch_feat.y-min(patch_feat.y)+1;
            
            pool(k,:) = pooling(patch_feat, Unsup, pyramid, meth);
            bndbox(k,:) = [x_lo y_lo x_hi y_hi];
%             
%             pool = pooling(patch_feat, Unsup, pyramid, meth);
%             
%             % predict the score
%             cur_dir = pwd;
%             cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
%             pred = predict(0, sparse(pool), svmmodel, [], 'col');
%             cd(cur_dir);
%             if pred
%                 bndbox(end+1,:) = [y_lo x_lo y_hi x_hi];
%             end
        end
        
        % predict score
        cur_dir = pwd;
        cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
        pred = predict(zeros(size(pool,1),1), sparse(pool'), svmmodel, [], 'col');
        cd(cur_dir);
        pidx = find(pred==1);
        all_bbox_svm = [all_bbox_svm; bndbox(pidx,:)];
        
        % direct sum
        p = [pool ones(size(pool,1),1)*svmmodel.bias];
        s = svmmodel.w*p';
        didx = find(s>=thresh);
        all_bbox_dsum = [all_bbox_dsum; bndbox(didx,:)];

    end
    I1 = nms(all_bbox_svm, 0.5);
    all_bbox_svm = all_bbox_svm(I1, [1:4 end]);
    I2 = nms(all_bbox_dsum, 0.5);
    all_bbox_dsum = all_bbox_dsum(I2, [1:4 end]);
    
    [n_det n_pos n_cor_det gt_bbox] = detection_perform(all_bbox_svm,obj);
    svm_info(1) = svm_info(1) + n_det;
    svm_info(2) = svm_info(2) + n_pos;
    svm_info(3) = svm_info(3) + n_cor_det;
    
    [n_det n_pos n_cor_det] = detection_perform(all_bbox_dsum,obj);
    dsum_info(1) = dsum_info(1) + n_det;
    dsum_info(2) = dsum_info(2) + n_pos;
    dsum_info(3) = dsum_info(3) + n_cor_det;
    
    [~, name] = fileparts(database.path{i});
    saveboxes(img, all_bbox_svm, gt_bbox, sprintf('%s/%s.jpg',save_svmpath,name))
    saveboxes(img, all_bbox_dsum, gt_bbox, sprintf('%s/%s.jpg',save_dsumpath,name))
    toc
end

svm_info(4) = svm_info(3)/svm_info(1);
svm_info(5) = svm_info(3)/svm_info(2);

dsum_info(4) = dsum_info(3)/dsum_info(1);
dsum_info(5) = dsum_info(3)/dsum_info(2);


function dataSet = extract_sift_from_mat(ps,gs,train_img_dir,all_mat_dir,train_feature_dir)
% Convert from mat files to JPG
% train_pos_database = makeDatabase_test_from_mat(fullfile(all_mat_dir,'car'),221,300);
% num_pos = 0;
% pos_img_dir = fullfile(train_img_dir,'car');
% neg_img_dir = fullfile(train_img_dir,'nonlap_negs');
% 
% if ~isdir(pos_img_dir)
%     mkdir(pos_img_dir);
% end
% if ~isdir(neg_img_dir)
%     mkdir(neg_img_dir);
% end
% 
% for i=1:train_pos_database.nframe
%     load(train_pos_database.path{i},'img','obj');
%     for j=1:length(obj)
%         num_pos = num_pos+1;
%         bbox = obj(j).bndbox;
%         patch = img(bboxcal_feat_unsup(2):bbox(4),bbox(1):bbox(3),:);
%         savepath = sprintf('%s/%.4d.jpg',pos_img_dir,num_pos);
%         imwrite(patch,savepath);
%     end
% end
% 
% train_neg_database = makeDatabase_test_from_mat(fullfile(all_mat_dir,'nonlap_negs_no_sky'),1,344);
% 
% for i=1:train_neg_database.nframe
%     load(train_neg_database.path{i},'img','obj');
%     for j=1:length(obj)
%         num_pos = num_pos+1;
%         bbox = obj(j).bndbox;
%         patch = img(bbox(2):bbox(4),bbox(1):bbox(3),:);
%         savepath = sprintf('%s/%.4d.jpg',neg_img_dir,num_pos);
%         imwrite(patch,savepath);
%     end
% end
% Extract SIFT features
addpath(genpath('../recognition'));
dataSet = siftExt(ps,gs,train_img_dir,train_feature_dir,0)
% dataSet = 'patch8_grid2_optresize0';


function [Unsup fname_save] = cal_feat_unsup(ps,gs,dataSet,train_feature_dir)
% Train Unsupervised feature
global meth codebookPath numHidden
numHidden = 128;
maxIter = 200;
switch meth
    case 'sae'
        fname_save = sprintf('SAE_resize%d_ps%d_gs%d_b%d_pb%g_pl%g',optResize,ps,gs,numHidden,pBias,pLambda);
        try
            load(sprintf(strcat(codebookPath,'%s.mat'),fname_save));
        catch
            disp('Running Sparse AE');
            sparseAE(numHidden,train_feature_dir,dataSet,fname_save,pBias,pLambda,codebookPath);
        end
    case 'kmeans_tri'
        fname_save = sprintf('kmeans_tri_ps%d_gs%d_b%d',ps,gs,numHidden);
        try
            load(sprintf(strcat(codebookPath,'%s.mat'),fname_save));
        catch
            disp('Running Kmeans Triangle')
            main_Kmeans_rev1(numHidden,train_feature_dir,dataSet,fname_save,maxIter,codebookPath)
        end
    case 'kmeans'
        fname_save = sprintf('kmeans_ps%d_gs%d_b%d',ps,gs,numHidden);
        try
            load(sprintf(strcat(codebookPath,'%s.mat'),fname_save));
        catch
            disp('Running Kmeans Hard')
            main_Kmeans_rev1(numHidden,train_feature_dir,dataSet,fname_save,maxIter,codebookPath)
        end
    case 'rbm'
        fname_save = sprintf('rbm_ps%d_gs%d_b%d',ps,gs,numHidden);
        try
            load(sprintf(strcat(codebookPath,'%s.mat'),fname_save));
        catch
            disp('Running RBM')
            sparseRBM(numHidden,train_feature_dir,dataSet,fname_save,pBias,pLambda,0);
        end
            
end
Unsup = load(sprintf(strcat(codebookPath,'%s.mat'),fname_save));
    

function bndbox = sliding_windows_frame(I,ps,gs,model)
    [im_h, im_w, ~] = size(I);
    remX = mod(im_w-ps/2,gs);
    offsetX = floor(remX/2)+1;
    remY = mod(im_h-ps/2,gs);
    offsetY = floor(remY/2)+1;
    
    [gridX,gridY] = meshgrid(offsetX+ps/2:gs:im_w-ps/2+1, offsetY+ps/2:gs:im_h-ps/2+1);
    bndbox = sift_detect(I, gridX, gridY, ps, model);
    
    
function bndbox = sift_detect(I, grwUnitid_x, grid_y, patch_size, svmmodel)
global Unsup pyramid meth
% parameters
num_patches = numel(grid_x);
bndbox = [];

I = im2double(uint8(I));

% for all patches
for i=1:num_patches
    % find window of pixels that contributes to this descriptor
    x_lo = grid_x(i) - (patch_size - ceil(patch_size/2));
    x_hi = grid_x(i) + ceil(patch_size/2) - 1;
    y_lo = grid_y(i) - (patch_size - ceil(patch_size/2));
    y_hi = grid_y(i) + ceil(patch_size/2) - 1;
    
    % calculate the mean pixel value for that patch
    patch = I(y_lo:y_hi, x_lo:x_hi, :);
    
    feat = pooling_feature(patch,Unsup,pyramid,meth);
%     feat = features(imresize(patch, [100 100]), 5);
%     feat = feat(:);
    cur_dir = pwd;
    cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
    pred = predict(0, sparse(feat), svmmodel, [], 'col');
    cd(cur_dir);
%     pred = svmpredict(0, feat, svmmodel);
    if pred
        bndbox(end+1,:) = [y_lo x_lo y_hi x_hi];
    end
end
        
function bndbox = find_HOG_grid(I, grid_x, grid_y, patch_size, svmmodel)
% parameters
num_patches = numel(grid_x);
bndbox = [];

I = im2double(uint8(I));

% for all patches
for i=1:num_patches
    % find window of pixels that contributes to this descriptor
    x_lo = grid_x(i) - (patch_size - ceil(patch_size/2));
    x_hi = grid_x(i) + ceil(patch_size/2) - 1;
    y_lo = grid_y(i) - (patch_size - ceil(patch_size/2));
    y_hi = grid_y(i) + ceil(patch_size/2) - 1;
    
    % calculate the mean pixel value for that patch
    patch = I(y_lo:y_hi, x_lo:x_hi, :);
    feat = features(imresize(patch, [100 100]), 5);
    feat = feat(:);
    cur_dir = pwd;
    cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
    pred = predict(0, sparse(feat), svmmodel, [], 'col');
    cd(cur_dir);
%     pred = svmpredict(0, feat, svmmodel);
    if pred
        bndbox(end+1,:) = [y_lo x_lo y_hi x_hi];
    end
end

function [n_det n_pos n_cor_det gt_bbox] = detection_perform(box,obj)
    gt_bbox = [];
    diff_bbox = [];
    n_pos = 0;
    n_det = size(box,1);
    n_cor_det = 0;
    
    for n=1:length(obj)
        if obj(n).difficult
            diff_bbox(end+1,:) = obj(n).bndbox;
        else
            n_pos = n_pos+1;
            gt_bbox(end+1,:) = obj(n).bndbox;
        end
    end
    if ~isempty(box)
        for b = 1:n_pos
            if ~isempty(gt_bbox)
                overlaps = boxoverlap(box, gt_bbox(b,:));
                if sum(overlaps > 0.5) > 0
                    n_cor_det = n_cor_det + 1;
                end
            end
        end   
        for b = 1:size(diff_bbox,1)
            overlaps_diff = boxoverlap(box, diff_bbox(b,:));
            if sum(overlaps_diff > 0.5) > 0
                n_det = n_det - 1;
            end
        end
    end
%     for i=1:n_pos
%         if sum(boxoverlap(gt_bbox,box(i,:))>.5) >= 1 & sum(boxoverlap(box,box(i,:))>.5) == 1
%             n_cor_det = n_cor_det+1;
%         end
%     end

    