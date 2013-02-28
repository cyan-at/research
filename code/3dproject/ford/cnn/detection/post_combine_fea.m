function [Xtrain, Xtest] = post_combine_fea(train_datadir, test_datadir, dataSet, K, pyramid)
%train_datadir, test_datadir, dataSet should be p*1 cell, p = number of features
%final feature dimension = p*K

% if ~exist('K', 'var') K = 512; end
% if ~exist('train_datadir','var') train_datadir = {'/mnt/neocortex/scratch/norrathe/data/pixel_ruler_train', '/mnt/neocortex/scratch/norrathe/data/color_hist_ruler_train',...
%     '/mnt/neocortex/scratch/norrathe/data/siftalign_ruler_train'}; end
% if ~exist('test_datadir','var') test_datadir = {'/mnt/neocortex/scratch/norrathe/data/pixel_ruler_test', '/mnt/neocortex/scratch/norrathe/data/color_hist_ruler_test',...
%     '/mnt/neocortex/scratch/norrathe/data/siftalign_ruler_test'}; end
% if ~exist('dataSet','var') dataSet = {'patch8_grid2_norm1_wonly1_resize1', 'patch8_grid2_norm0', 'patch8_grid2'}; end
% if ~exist('pyramid', 'var') pyramid = [1 2]; end

Xtrain = [];
Xtest = [];
for i = 1 : length(train_datadir)
fea_all = fea_ext(train_datadir{i}, dataSet{i});

km = Kmeans(K, 'tri');       
Data.Xtrain = double(fea_all); 
Data.numchannels  = 1; Data.learner = [];
km.train_lite([], Data);

sp = Pool('sp', 'max' , [], [],pyramid);
Xtrain_curr = fea_for_classification(fullfile(train_datadir{i},dataSet{i}), km, sp);
Xtest_curr = fea_for_classification(fullfile(test_datadir{i},dataSet{i}), km, sp);

Xtrain = [Xtrain ; Xtrain_curr];
Xtest = [Xtest; Xtest_curr];
end