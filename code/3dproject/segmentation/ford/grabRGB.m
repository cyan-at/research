function [pc, rgbarray, idx] = grabRGB(scanFile, scanFolder)
close all;
%this function will take a given SCAN mat file and return a N x 3 matrix of
%rgb values, or 0 0 0 for black if rgb isn't found for that location, N x 3
%of pc
%scanFile     
%load the scan
load(scanFile); pc = SCAN.XYZ';
%load params
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat';
load(paramFile);
rgbarray = zeros(size(SCAN.XYZ,2), 3);
%loop over all 5 camera images
set = [];
for i = 1:5
    msg = sprintf('reading from camera %d',i); disp(msg);
    %get the image
    im_name = strcat(scanFolder,'image',num2str(i-1),'.ppm'); 
    I = imread(im_name);
    I = imresize(I, [1232,1616]);
    I_rotated = imrotate(I, -90);
    I_rotated = flipdim(I_rotated,2);
    %display the image
%     figure; imshow(I_rotated);
%     hold on;
    %get the pixels
    K = PARAM(i).K;
    R = PARAM(i).R;
    t = PARAM(i).t;
    pixels = K*SCAN.Cam(i).xyz;
    ycoord = round(pixels(1,:)./pixels(3,:));
    xcoord = round(pixels(2,:)./pixels(3,:));
    p = round(SCAN.Cam(i).pixels)';
    for j = 1:length(xcoord)
        m = SCAN.Cam(i).points_index(j);
        coord = p(j,:); x = coord(1); y = coord(2);
        rgb = I_rotated(x,y,:);
        rgbarray(m,:) = [rgb(1),rgb(2),rgb(3)];
        set = [set m];
    end
    close;
end
idx = unique(set);
%now the rgbarray is constructed
end

