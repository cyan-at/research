clear all;
addpath ./../ObjOriented

%simple example
% dataSet = [1,1,1,0,0,0;1,0,1,0,0,0;1,1,1,0,0,0;0,0,1,1,1,0;0,0,1,1,0,0;0,0,1,1,1,0];
% dataSet = dataSet'; %columns of dataSet
% rbm = RBM(2);
% rbm.setBatchSize(2);
% rbm.train(dataSet);

%more complicated example
feat_method = 'sift';
rescaleSize = 250;              % The size to which all patches will be rescaled
rootPath = '~/scratch/3dproject/data/experiments/experiment2';
% Where all temp data, including features, obj, results, are stored.
tempFolder = '/home/jumpbot/3dproject/experiment2/testTemp';

featurePath = sprintf('%s/%s_sz%d_features/train_features', tempFolder, feat_method, rescaleSize);
fmtFeatPath = sprintf('%s/%s_sz%d_features/fmt_%s_features', tempFolder, feat_method, ...
    rescaleSize, feat_method);
codebookPath = sprintf('%s/codebook', tempFolder);

% The root paths of SIFT features.
trainFeatPath = sprintf('%s/%s_sz%d_features/train_features', tempFolder, feat_method, rescaleSize);
testFeatPath = sprintf('%s/%s_sz%d_features/test_features',  tempFolder, feat_method, rescaleSize);

% Path to store temporary training object.
tempObjPath = sprintf('%s/temp_obj', tempFolder);
if ~exist(tempObjPath, 'dir') mkdir(tempObjPath); end

% The path of training set activations and testing set activations and
% labels. Ready to be passed into SVM.
bundleForSVMPath = sprintf('%s/SVM_bundle', tempFolder);

optcolor = 'gray';              % 
patchSize = 16;                 % Size of patches to extract features.
gridSpacing = 2;                % Step size between patches.
rescaleSize = 250;              % The size to which all patches will be rescaled
                                % before feature extraction.
maxImSize = 300;                % 
nrml_threshold = 1;             %
suppression = 0.2;              %

% Extract raw sift features.
featObj = FeatExtract(optcolor, patchSize, gridSpacing, rescaleSize, ...
                maxImSize, nrml_threshold, suppression, feat_method);   
           
featExtAll = FeatExt_TrainTest(rootPath, tempFolder);
featExtAll.extract(featObj);

% % Format sift features.
fmtFea = FormatFeatures;
fmtFea.setPath(featurePath, fmtFeatPath);
formatted_fea = fmtFea.format;

rbm = RBM();
unsup_method = 'RBM';
saveName = sprintf('%s_%s_ps%d_gs%d_b%d', unsup_method, feat_method, patchSize, gridSpacing, rbm.numHidden);
objCompletePath = sprintf('%s/obj_%s.mat', tempObjPath, saveName);
try
    load(objCompletePath);
catch
	disp('==================================================');
	disp('Training %s features...rbm');
	disp('==================================================');
	rbm.train(formatted_fea,10);
    	%save the rbm
    	if ~exist(tempObjPath, 'dir') mkdir(tempObjPath); end
	save(objCompletePath, 'rbm');
end
[tr_fea, tr_label, ts_fea, ts_label] = rbm.calcActLabel(trainFeatPath, testFeatPath, bundleForSVMPath, saveName);
resultName = sprintf('%s/Results_%s', tempFolder, saveName);
modelCompletePath = sprintf('%s/model_%s.mat', tempObjPath, saveName);
SVMobj = SVM_car;
SVMobj.reportAccTrain(tr_fea, tr_label, ts_fea, ts_label, modelCompletePath, resultName);


