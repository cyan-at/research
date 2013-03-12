function [score, target] = resolve(cnnDetections,groundTruths,threshold)
addpath /mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/classification/
%evaluates the detection results
%for every cnn detection, check if the bndbox overlaps any groundTruth with
%greater than threshold overlap. If the max overlap is above, then mark
%that cnn Detection's target as 1, otherwise 0
score = cnnDetections(:,6);
target = zeros(size(cnnDetections,1),1);
for i = 1:size(cnnDetections,1)
    o = boxoverlap(groundTruths(:,2:5),cnnDetections(i,1:4));
    [c,idx] = max(o);
    if (c >= threshold)
        target(i) = 1;
    end
end

end