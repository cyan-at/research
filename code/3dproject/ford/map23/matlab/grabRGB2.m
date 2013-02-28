function [pc, info, idx] = grabRGB2(scanFile, scanFolder)
close all;
%this function will take a given SCAN mat file and return a N x 3 matrix of
%rgb values, or 0 0 0 for black if rgb isn't found for that location, N x 3
%of pc
%scanFile     
%load the scan
load(scanFile); pc = SCAN.XYZ';
%load params
paramFile = '/mnt/neocortex/data/Ford/IJRR-Dataset-1-subset/PARAM.mat';
load(paramFile);
info = zeros(size(SCAN.XYZ,2), 6);
%loop over all 5 camera images
set = [];
for i = 1:5
    %msg = sprintf('reading from camera %d',i); disp(msg);
    %get the image
    im_name = strcat(scanFolder,'image',num2str(i-1),'.ppm'); 
    I = imread(im_name);
    I = imresize(I, [1232,1616]);
    I_rotated = imrotate(I, -90);
    I_rotated = flipdim(I_rotated,2);
    %get the pixels
    K = PARAM(i).K;
    pixels = K*SCAN.Cam(i).xyz;
    ycoord = round(pixels(1,:)./pixels(3,:));
    xcoord = round(pixels(2,:)./pixels(3,:));
    pnew = [0,-1;1,0]*[0,-1;1,0]*[0, -1;1,0]*[xcoord;ycoord]; 
    pnew(2,:) = pnew(2,:) + 1616*ones(1,size(pnew,2));
    %scatter(pnew(1,:)',pnew(2,:)',2);
    %p = [pnew(1,:)',pnew(2,:)'];
    p = round(SCAN.Cam(i).pixels)';
    for j = 1:length(SCAN.Cam(i).points_index)
        m = SCAN.Cam(i).points_index(j);
        coord = p(j,:); x = coord(1); y = coord(2);
        rgb = I_rotated(x,y,:);
        %construct a datapoint with [r g b x y cam]
        if (sum(info(m,1:3)) == 0)
            info(m,1:3) = [rgb(1),rgb(2),rgb(3)];
            info(m,4:6) = [coord(1),coord(2),i];
            set = [set m];
        end
    end
    close;
end
idx = unique(set);
%now the rgbarray is constructed
end

