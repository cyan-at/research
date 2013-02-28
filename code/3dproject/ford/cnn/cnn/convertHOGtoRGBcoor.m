function [ rgb_bndbox ] = convertHOGtoRGBcoor( img, sbin, bb )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

rgb_bndbox = bb*sbin;
% for i=1:size(bb,1)
%     %sbin = 8;
%     bbox = bb(i,:)+sbin;
% 
%     % Pad image by 2 blocks so that the size doesnt change when doing HOG
%     I = zeros(size(img,1)+2*sbin,size(img,2)+2*sbin,3);
%     I(sbin+1:sbin+size(img,1),sbin+1:sbin+size(img,2),:) = img;
%     % I = IMAGES{i};
% 
% %     h2 = features(im2double(I),sbin);
%     [gridX gridY] = meshgrid(2:round(size(I,1)/sbin)-1,2:round(size(I,2)/sbin)-1);
% 
%     % HOG coordinate
%     gridX = gridX(:);
%     gridY = gridY(:);
% 
%     % transform to image coordinate, NOT SURE if need 0.5
%     imGridX = (gridX+0.5)*sbin+0.5;
%     imGridY = (gridY+0.5)*sbin+0.5;
% 
%     % find grid that is closest to bounding box
%     dist = (imGridX-bbox(1)).^2+(imGridY-bbox(2)).^2;
%     [temp, idx] = min(dist);
%     
%     dist = (imGridX-bbox(3)).^2+(imGridY-bbox(4)).^2;
%     [~, idx2] = min(dist);
%     
% %     hog_bndbox(i,:) = [gridX(idx) gridY(idx) gridX(idx2) gridY(idx2)];
% 
%     rgb_bndbox(i,:) = [gridX(idx) gridY(idx) gridX(idx)+round((bbox(3)-bbox(1))/sbin) gridY(idx)+round((bbox(4)-bbox(2))/sbin)];
% 
% %     visualizeHOG(h2(hog_bndbox(2):hog_bndbox(4), hog_bndbox(1):hog_bndbox(3),:));
% end

end

