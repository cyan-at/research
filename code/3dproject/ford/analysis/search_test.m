model_location = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/analysis/search_across_parameters/pos0.30_neg0.60_xCNN_y3D_do/model.mat';
load(model_location);
set(0,'DefaultFigureVisible','off');
cnnfeature = struct(); cnnfeature.matrix_idx = 1; cnnfeature.name = 'CNN';
twofeature = struct(); twofeature.matrix_idx = 2; twofeature.name = '2D';
threefeature = struct(); threefeature.matrix_idx = 3; threefeature.name = '3D';
xfeature = cnnfeature;
yfeature = threefeature;
opt_standardize = true;

ap = refine_with_search_test(model,'pos0.30_neg0.60_xCNN_y3D_do','refine_with_search',5,xfeature,yfeature,opt_standardize);