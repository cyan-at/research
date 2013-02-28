function [Xtrain, Xtest] = pre_combine_fea(train_datadir, test_datadir, dataSet, K, pyramid)
%train_datadir, test_datadir, dataSet should be p*1 cell, p = number of features
% if ~exist('K', 'var') K = 512; end
% if ~exist('train_datadir','var') train_datadir = {'/mnt/neocortex/scratch/norrathe/data/pixel_ruler_train', '/mnt/neocortex/scratch/norrathe/data/color_hist_ruler_train',...
%     '/mnt/neocortex/scratch/norrathe/data/siftalign_ruler_train'}; end
% if ~exist('test_datadir','var') test_datadir = {'/mnt/neocortex/scratch/norrathe/data/pixel_ruler_test', '/mnt/neocortex/scratch/norrathe/data/color_hist_ruler_test',...
%     '/mnt/neocortex/scratch/norrathe/data/siftalign_ruler_test'}; end
% if ~exist('dataSet','var') dataSet = {'patch8_grid2_norm1_wonly1_resize1', 'patch8_grid2_norm0', 'patch8_grid2'}; end
% if ~exist('pyramid', 'var') pyramid = [1 2]; end

fea_all = fea_ext_all(train_datadir, dataSet);

%normalize fea_all
mu = mean(fea_all, 2);
sigma = std(fea_all,[],2);
fea_all = bsxfun(@rdivide, bsxfun(@minus, fea_all, mu), sigma);

km = Kmeans(K, 'tri');       
Data.Xtrain = double(fea_all); 
Data.numchannels  = 1; Data.learner = [];
km.train_lite([], Data);

sp = Pool('sp', 'max' , [], [],pyramid);
Xtrain = fea_for_classification_multi({fullfile(train_datadir{1},dataSet{1}), fullfile(train_datadir{2},dataSet{2}), fullfile(train_datadir{3},dataSet{3})}, km, sp, mu, sigma);
Xtest = fea_for_classification_multi({fullfile(test_datadir{1},dataSet{1}), fullfile(test_datadir{2},dataSet{2}), fullfile(test_datadir{3},dataSet{3})}, km, sp, mu, sigma);
