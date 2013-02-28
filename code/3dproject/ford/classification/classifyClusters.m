function classifyClusters(clusterLocation, encoders, models, names, parameters)
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'library/')));
% performs binary classification on segmentation results
% path is the location of the cluster pcd files
% first, convert them all to mat files
matDir = fullfile(clusterLocation,'/../classified/mat/');
pcdDir = fullfile(clusterLocation,'/../classified/pcd/');
% disp(matDir);
if (~exist(matDir,'dir'))
    mkdir(matDir);
end
if (~exist(pcdDir,'dir'))
    mkdir(pcdDir);
end
% parameters
radius = 1;
imgW = 16;
minN = 10;

% make text file for classification results
%text file stores: clusterID [bndbox] [ford label acc score] [kitti label acc
%score]
detectionFile = strcat(pcdDir,'detection.txt');
fid = fopen(detectionFile,'w');

allPCD = catalogue(clusterLocation,'pcd');
numCars = 0;
numNots = 0;
for i = 1:length(allPCD)    
    pcdFile = cell2mat(allPCD(i));
    disp(pcdFile);
    pc = pcd2mat(pcdFile);
    
    [~,y,~] = fileparts(pcdFile);
    detectionContent = sprintf('%s:',y);
    
    %get the bndbox
    [ bndbox, cam, scan ] = extractBndbox(pc);
    detectionContent = strcat(detectionContent,num2str([bndbox,cam,scan]));
    
    pc = pc(:,1:3)';
    % then compute spin images on them
    feaArr = compSpinImages(pc', radius, imgW, minN);
    feaArr = reshape(feaArr,imgW*imgW,size(pc,2));
    feat.feaArr = single(feaArr);
    feat.width = size(feaArr,2);
    feat.height = size(feaArr,2);
    feat.x = 1:size(feaArr,2);
    feat.y = 1:size(feaArr,2);
    % then do pooling
    disp('computing pool');
    labels = []; accs = []; scores = [];
    
    name = y;
    obj = struct();
    obj.pc = pc;
    
    for j = 1:length(encoders)
        encoder = encoders(j);
        pool = pooling(feat, encoder, parameters);
        % then apply them to trained models
        [label, acc , score] = predict(double(1),sparse(pool),models(j),[],'col');
        labels(j) = label; accs(j) = acc; scores(j) = score;
        if (label == 1)
            name = strcat(name,'_',names{j},'_car');
        else
            name = strcat(name,'_',names{j},'_not');
        end
        detectionContent = strcat(detectionContent,'|',num2str([label, acc , score]));
    end
    
    % save the pool and point cloud under this name
    matFileName = fullfile(matDir,strcat(name,'.mat'));
    disp(matFileName);
    save(matFileName,'obj');
    % save the point cloud under that name
    newpcdFileName = fullfile(pcdDir,strcat(name,'.pcd'));
    cpCmd = sprintf('cp %s %s',pcdFile,newpcdFileName);
    disp(cpCmd);
    system(cpCmd);
    %add the detection content
    fprintf(fid,strcat(detectionContent,'\n'));
end
fclose(fid);
end
