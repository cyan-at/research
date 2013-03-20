function = grabPoints(points)
%using this function in overlapCNNv2, mainly for visualizing / debuggin
%when you have a cnn detection, grabPoints(points found inside of cnn)
%later, get the mode of the cluster id of these points, and modify cnn
%bounding box that way
pointcloud = zeros(size(points,1),3);
%generate pointcloud from points
%create a xyz value, with x and y from the point
range = points(:,4);
z = points(:,5);
horz = points(:,6);
pointcloud(:,1) = range(:); %range is the x dimension
pointcloud(:,2) = horz(:); %horz(i); % x;
pointcloud(:,3) = -z(:);
%save the pointcloud
testloc = '/home/jumpbot/jumpbot/data/3dproject/withlabels/test/obj1673/depth_map.pcd';
mat2pcd(pointcloud,testloc);
pclviewer(testloc);
delete(testloc);
end