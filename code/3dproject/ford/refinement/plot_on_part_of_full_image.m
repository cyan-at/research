function [coord] = plot_on_part_of_full_image(I,pointcloud,K,R,t,MappingMatrix,yoffset,sort_mode)
%% This function projects the pointcloud on the corresponding part of full
%% image. The image which we get from LB3 camera is stacked in a long image
%% from all the six sensors
% inputs
% I = stacked image from LB3
% yoffset = the y coordiante of the start of the image in the stack
% pointcloud = 3D points [3xn] in camera reference frame for this part image 
% K = internal camera matrix of this sensor.

col = size(I,2) - 1;
row = size(I,1)/5 - 1;
imgWidth = size(I,2);
imgHeight = size(I,1);

%range of points
range_cam = pointcloud.*pointcloud;
range = sqrt(sum(range_cam,1));
[sorted_range ii_r] = sort(range);

%Height above the ground plane 
%The camera is oriented such that Z coordinate is pointing outward
H_cam = pointcloud(1,:);
horzrange = pointcloud(2,:);

[sorted_Z ii_z] = sort(H_cam);
rbasedZ = H_cam(ii_r);
rbasedHorz = horzrange(ii_r);

image_points = K*pointcloud;
tempX = image_points(1,:)./ image_points(3,:);
tempY = image_points(2,:)./ image_points(3,:);

%Image points sorted with Z/range coordinate
if(sort_mode == 'r') %sort based on range from camera
    tempX = tempX(ii_r);
    tempY = tempY(ii_r);
    temp_min = 0.5;
    step = 1; % in meters
elseif(sort_mode == 'z') % sort based on height above the ground plane
    tempX = tempX(ii_z);
    tempY = tempY(ii_z);
    temp_min = -2.5;
    step = 0.1;
end

index = find(tempX(1,:) > 1 & tempX(1,:) < col &  tempY(1,:) > 1 & tempY(1,:) < row); 
X_final = tempX(index);
Y_final = tempY(index);

if(sort_mode == 'r')
    sorted = sorted_range(index);
elseif(sort_mode == 'z')
    sorted = sorted_Z(index);
end
sortedZ = rbasedZ(index);
horzrange2 = rbasedHorz(index);

n = size(X_final,2);

numColors = 50;
color = hsv(numColors);

% I = imrotate(I,-90); 
% imshow(I); hold on; grid on; axis on;

%distort pixels
[X_distorted Y_distorted]= distort_pixels(X_final ,Y_final,squeeze(MappingMatrix),row+1,col+1);
X_final = X_distorted;
Y_final = Y_distorted + yoffset;

% group into 50 different segments
% plot each segment with different color
temp_index = find(Y_final > (yoffset+1) & Y_final < (yoffset + row-1) & X_distorted > imgWidth/3 & X_distorted < imgWidth);
X_final = X_final(temp_index);
Y_final = Y_final(temp_index);
sorted = sorted(temp_index);
sortedZ = sortedZ(temp_index);
horzrange2 = horzrange2(temp_index);

%Project the points with different colors
coord = [];
for i = 1:numColors
    %if using r sorting, and as we increase i, we get farther away
    temp_index = find(sorted(:) >= temp_min & sorted(:) < (temp_min + step));
    temp_X_final = X_final(temp_index);
    temp_Y_final = Y_final(temp_index);
    temp_min = temp_min + step;
    %let entry be [u,v,distancegroup,actualrange,z,horz]
    range = sorted(temp_index)';
    z = sortedZ(temp_index)';
    horz = horzrange2(temp_index)';
    %disp(max(z)); disp(min(z));
    entry = [row*5-temp_Y_final, temp_X_final,repmat(i,size(temp_X_final,1),1),range,z,horz];
    coord = [coord; entry];
    %scatter(entry(:,1),entry(:,2),2.5,color(i,:));
end
end