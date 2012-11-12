function classifyClusters(clusterLocation, model)
addpath(genpath('/home/charlie/Desktop/research/code/library/'));
% performs binary classification on segmentation results
% path is the location of the cluster pcd files
% first, convert them all to mat files
matDir = fullfile(clusterLocation,'/../mat/');
disp(matDir);
if (~exist(matDir,'dir'))
    mkdir(matDir);
end
d = dir(clusterLocation);
nameFolds = {d.name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    pcdFile = fullfile(clusterLocation,cell2mat(nameFolds(i)));
    disp(pcdFile);
    pc = pcd2mat(pcdFile);
    [~,y,z] = fileparts(pcdFile);
    matFileName = fullfile(matDir,strcat(y,z));
    disp(matFileName);
    save(matFileName,'pc');
    % then compute spin images on them
    cal_spinImages_feat(strcat(y,z), matDir,pc,1,16,10)
    % then do pooling
    
    % then apply them to trained models
    
end
end
