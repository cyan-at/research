function model  =  car_detection_verif(cls, n, note, ps, gs, train_feature_dir, all_mat_dir, train_img_dir, method)
% car_detection(cls, n, note)
% Train and score a model with 2*n components.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG) features'
if ~exist('cls','var'), cls = 'car'; end
if ~exist('n','var'), n = 3; end
if ~exist('note','var'), note = datestr(datevec(now()), 'HH-MM-SS'); end
if ~exist('sbin','var'), sbin = 4; end
if ~exist('numperframe','var'), numperframe = 6; end
if ~exist('all_mat_dir','var'), all_mat_dir = '~/scratch/norrathe/data/experiment1/mat/resize_split_all_pos_neg'; end
if ~exist('train_img_dir','var'), train_img_dir = '~/scratch/norrathe/data/car_patches/pre_trained_baseline'; end
if ~exist('train_feature_dir','var'), train_feature_dir = '~/scratch/norrathe/data/car_feature/pre_trained_baseline/train'; end
if ~exist('method','var'), method = 'kmeans'; end
if ~exist('ps','var'), ps = 16; gs = 4; end

globals_car;
car_init;

% record a log of the training procedure
diary([cachedir cls '.log']);
model = get_model();
% model = car_train(cls, n, note, sbin);
% lower threshold to get high recall
model.thresh = min(-1.1, model.thresh);


%% Convert from mat files to JPG
% train_pos_database = makeDatabase_test_from_mat(fullfile(all_mat_dir,'car'),221,220);
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
%         patch = img(bbox(2):bbox(4),bbox(1):bbox(3),:);
%         savepath = sprintf('%s/%.4d.jpg',pos_img_dir,num_pos);
%         imwrite(patch,savepath);
%     end
% end
% 
% train_neg_database = makeDatabase_test_from_mat(fullfile(all_mat_dir,'nonlap_negs'),221,250);
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

%% Extract SIFT features
addpath(genpath('../recognition'));
dataSet = siftExt(ps,gs,train_img_dir,train_feature_dir,0)
% dataSet = 'patch8_grid2_optresize0';

%% Train Unsupervised feature
codebookPath = '~/scratch/norrathe/codebook/';
numHidden = 1000;
maxIter = 200;
pyramid = 1;
switch method
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
        fname_save = sprintf('kmeans_tri_ps%d_gs%d_b%d',ps,gs,numHidden);
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

%% Train SVM
[tr_fea, ~, tr_label] = get_features(fname_save,method,pyramid,train_feature_dir,[],[],codebookPath,'nonlap');
svmmodel = train_svm('linear',tr_fea,tr_label,5,1);
Unsup = load(sprintf(strcat(codebookPath,'%s.mat'),fname_save));

%%% =========================================== %%%
%% detection (SHOULD BE CHANGED)
% output: extracted images with labels

% database = makeDatabase_test();
% thresholds = linspace(-.6, -1.5, 10);
database = makeDatabase_test_from_mat(fullfile(all_mat_dir,'car'),1,220);
% recall = zeros(size(thresholds));
% precision = zeros(size(thresholds));

% parfor i=1:length(thresholds)
    fprintf('%d thresh: %g\n',i,model.thresh);
    savepath = sprintf('/mnt/neocortex/scratch/norrathe/data/car_detection/pre_trained_verif/thresh%g',model.thresh);
    [recall precision] = car_detect_frame_verif(model,svmmodel,Unsup,method,database,savepath,1,1,1,model.thresh);
% end

% plot(recall,precision);
% 
% title('Precision/Recall for car');
% xlabel('Recall');
% ylabel('Precision');
% savepath = '/mnt/neocortex/scratch/norrathe/data/car_detection/pre_trained_verif/recall_prec.png';
% saveas(gcf,savepath);