function [ feat ] = calcSIFT( img, patchSize, stepSize, suppression)
% Given an image, calculate the SIFT descriptor of it.
% img is a regular RGB image.

%% Specify Parameters.

if ~exist('patchSize','var')
    suppression = 16;
end

if ~exist('stepSize','var')
    stepSize = 2;
end

if ~exist('suppression','var')
    suppression = 0.2;
end

%% Calculation.

[im_h, im_w, ~] = size(img);

I = im2double(rgb2gray(img));

remX = mod(im_w - patchSize/2, stepSize);
offsetX = floor(remX / 2) + 1;
remY = mod(im_h - patchSize/2, stepSize);
offsetY = floor(remY / 2) + 1;

[gridX, gridY] = meshgrid(offsetX + patchSize/2 : stepSize : im_w-patchSize/2 + 1, ...
    offsetY + patchSize/2 : stepSize : im_h-patchSize/2 + 1);

feaArr = sp_find_sift_grid(I, gridX, gridY, patchSize, 0.8);
feaArr = sp_normalize(feaArr, 1, suppression);

gridX = gridX(:) - 0.5;
gridY = gridY(:) - 0.5;

feat.feaArr = single(feaArr');

feat.x = gridX(:);
feat.y = gridY(:);

feat.width = im_w;
feat.height = im_h;

end

