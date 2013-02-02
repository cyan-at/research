function removeGroundFromPCD( pcdfile, targetfile, threshold )
%use 0.3 as the threshold
%REMOVEGROUND will find the mode z value for N x 3 pc struct
%then remove all the points with z values within a threshold of that value
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/utilities/')));
pc = pcd2mat(pcdfile);
%compute the mode
zEstimate = mode(pc(:,3));
originalCount = size(pc,1); 
criteria = (abs(pc(:,3)-zEstimate) >= threshold); 
newpc = pc(criteria,:);
disp(sprintf('%d points left',originalCount-sum(criteria)));
%write it to targetFile
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/utilities/matlab/mat2pcd';
disp('writing to pcd');
mat2pcdford(newpc, targetfile);
end
