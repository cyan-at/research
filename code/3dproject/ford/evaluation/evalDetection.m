function [pred_bbox gt m acc] = evalDetection(detDir,root)
%evaluates the detection results in detDir assuming a specific detection
%structure with working directories at root
addpath /mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/

%get the map file
fid = fopen(strcat(detDir,'map.txt'),'r');
map = textscan(fid,'%d %s', 'Delimiter', ' ');
idx = map{1}; scene = map{2};
fclose(fid);

fs = catalogue(root,'folder');
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i)),'/'); disp(workingPath);
    %for every scene, get the cnn detections for this scene
    cnnDetections = grabCNN(idx, scene, detDir, cell2mat(fs(i)));
    %cnnDetections is a n x 6 matrix of [bndbox, cam, confidence]
    
    %apply non-maximal suppression on detections
    idx=nms(cnnDetections,.5);
    cnnDetections = cnnDetections(idx,:);
    
    %et the ground truths and difficult or 
    groundTruths = grabGroundTruths(workingPath);
    %groundTruths will be n x 6 of cam bndbox difficult
    
    %evaluate cnn detections, generate a binary array of 1's and 0's and
    %the corresponding scores
    threshold = 0.5;
    [score, target] = evaluate(cnnDetections,groundTruths,threshold);
    [prec, tpr, fpr, thresh] = prec_rec(score, target,'plotPR',1);
    
end

end