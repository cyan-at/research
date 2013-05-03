
%overhead
cnnfeature = struct(); cnnfeature.matrix_idx = 1; cnnfeature.name = 'CNN';
twofeature = struct(); twofeature.matrix_idx = 2; twofeature.name = '2D';
threefeature = struct(); threefeature.matrix_idx = 3; threefeature.name = '3D';

%set search parameters
exp_desc = 'initial_test';
opt_standardize = true;
xfeature = cnnfeature;
yfeature = threefeature;
posWeight = 0.1;
negWeight = 0.1;
iteration_step = 5;

%load data
[pos_scores,neg_scores] = gather_data();
rbf_model_name = train_rbf_model(pos_scores,neg_scores,xfeature,yfeature,posWeight,negWeight,opt_standardize);
refine_test(rbf_model_name,exp_desc,iteration_step,xfeature,yfeature,opt_standardize);