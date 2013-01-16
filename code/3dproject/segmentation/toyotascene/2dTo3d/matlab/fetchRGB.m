function fetchRGB(i,opt)
%this script goes through every scan and computes the rgb values for a
%given xyz
loadPaths;
t = cell2mat(traindir(i));
scanFile = getScanFile(t);
disp(scanFile);
scan = readscan(scanFile);
scan = scan(1:3,:)';
%compute x
x = computeX(i, opt);
temp = scan*x;
%get the image, and get the rgb values
ppmFile = getPpmFile(t);
im = imread(ppmFile);
imsize = size(im);
[temp,idx] = getValidUV(temp, imsize);
temp = round(temp);
rgbs = zeros(length(temp),3);
for j = 1:length(temp)
    rgbs(j,:) = reshape(im(temp(j,1),temp(j,2),:),1,3);
end
%write the rgbs to the new xyzrgb file
[q, y, z] = fileparts(scanFile);
targetPCDFile = strcat(q,'/',y,'_colored.pcd');
writeXYZRGB(targetPCDFile,scan,rgbs,idx);
end
