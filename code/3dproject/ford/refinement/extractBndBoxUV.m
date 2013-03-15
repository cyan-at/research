function [ bndbox ] = extractBndBoxUV(points)
%READCLUSTERANDMAP this function takes a clusterpcd, and for each point in
%cluster pcd, try to find it under classified/pcd/cars*.pcd
%combined pcd, try to find it directly, preloaded, given as a struct
%load the pcd file
%combined is now a n x 11 matrix [x y z rgb r g b pixelx pixely cam scan]
%find the pixelx, pixely values
pixeluv = points(:,1:2);
pixeluv = flipdim(pixeluv,2);
lowx = min(pixeluv(:,1));
highx = max(pixeluv(:,1));
lowy = min(pixeluv(:,2));
highy = max(pixeluv(:,2));
bndbox = [lowy,lowx,highy,highx];
end

