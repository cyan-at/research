%load a test pointcloud
%call RANSAC on it

ransacDistance = 0.5;
[B, P, inliers] = ransacfitplane(XYZ, ransacDistance, 0);