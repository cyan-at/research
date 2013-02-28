function [ bndbox, cam, scan ] = readClusterAndMap(clustermat)
%READCLUSTERANDMAP this function takes a clusterpcd, and for each point in
%cluster pcd, try to find it under classified/pcd/cars*.pcd
%combined pcd, try to find it directly, preloaded, given as a struct
%load the pcd file
%combined is now a n x 11 matrix [x y z rgb r g b pixelx pixely cam scan]
clear obj; load(clustermat);
%find the pixelx, pixely values
pixelxy = obj.pc(:,8:9);
cam = mode(obj.pc(:,10));
scan = mode(obj.pc(:,11));

lowx = min(pixelxy(:,1));
highx = max(pixelxy(:,1));
lowy = min(pixelxy(:,2));
highy = max(pixelxy(:,2));

bndbox = [lowy,lowx,highy,highx];
end

