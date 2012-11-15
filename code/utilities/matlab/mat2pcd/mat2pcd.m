function [ pcdFile ] = mat2pcd( obj, targetFileName )
% This function takes the mat files that store point clouds of the Ford /
% Toyota data set
% assumes that the obj has a field 'pointcloud' that is a matrix of 3 x N
% saves the pcd file to some directory specified by 'targetFileName'
pc = obj.pointcloud';

end

