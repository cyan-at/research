function [rec,prec,ap] = evalDetectionv2(detDir,root)
%evaluates the detection results in detDir assuming a specific detection
%structure with working directories at root
addpath /mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/

%get the map file
fid = fopen(strcat(detDir,'map.txt'),'r');
map = textscan(fid,'%d %s', 'Delimiter', ' ');
idx = map{1}; scene = map{2};
fclose(fid);

fs = catalogue(root,'folder');
scores = []; targets = [];
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i)),'/'); disp(workingPath);
    %for every scene, get the cnn detections for this scene
    cnnDetections = grabCNN(idx, scene, detDir, cell2mat(fs(i)));
    %cnnDetections is a n x 6 matrix of [bndbox, cam, confidence]
    
    %apply non-maximal suppression on detections
    nmsi=nms(cnnDetections,.5);
    cnnDetections = cnnDetections(nmsi,:);
    
    %et the ground truths and difficult or 
    groundTruths = grabGroundTruths(workingPath);
    %groundTruths will be n x 6 of cam bndbox difficult
    
    %evaluate cnn detections, generate a binary array of 1's and 0's and
    %the corresponding scores
    threshold = 0.5;
    [score, target] = resolve(cnnDetections,groundTruths,threshold);
    scores = [scores; score]; targets = [targets; target];
end
[prec, tpr, ~, ~] = prec_rec(scores, targets);
rec = [0; tpr];
prec = [1 ; prec];

%compute ap section
ap=0;
for t=0:0.05:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/21;
end
end