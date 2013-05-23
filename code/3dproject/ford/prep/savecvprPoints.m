function savecvprPoints(points,location)
%saves cvprPoints as a pointcloud in a mat file
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

pointcloud = zeros(size(points,1),3);
%generate pointcloud from points
%create a xyz value, with x and y from the point
range = points(:,4);
z = points(:,5);
horz = points(:,6);
pointcloud(:,1) = range(:); %range is the x dimension
pointcloud(:,2) = horz(:); %horz(i); % x;
pointcloud(:,3) = -z(:);
%save the pointcloud as a mat file for training classifier
save(location,'pointcloud');
end