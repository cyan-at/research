model_location = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/analysis/search_across_parameters/pos0.30_neg0.60_xCNN_y3D_do/model.mat';
load(model_location);
set(0,'DefaultFigureVisible','off');
cnnfeature = struct(); cnnfeature.matrix_idx = 1; cnnfeature.name = 'CNN';
twofeature = struct(); twofeature.matrix_idx = 2; twofeature.name = '2D';
threefeature = struct(); threefeature.matrix_idx = 3; threefeature.name = '3D';
xfeature = cnnfeature;
yfeature = threefeature;
opt_standardize = true;
interval = 5;

%just cnn detection
% m = just_cnn(interval);
% saveDir = sprintf('%s/summary/just_cnn/',pwd);
% ensure(saveDir);
% plotRCPC(m.pc,m.rc,m.ap,'cnn + nms',saveDir);
% disp(saveDir);

%just 3D detection
m = just_3D(interval);
saveDir = sprintf('%s/summary/just_three/',pwd);
ensure(saveDir);
plotRCPC(m.pc,m.rc,m.ap,'3D + nms',saveDir);
disp(saveDir);
% 
% %just 2D detection
% m = just_3D(interval);
% saveDir = sprintf('%s/summary/just_cnn/',pwd);
% ensure(saveDir);
% plotRCPC(m.pc,m.rc,m.ap,'cn + nms',saveDir);
% disp(saveDir);

%combining the results from CNN and HOG
