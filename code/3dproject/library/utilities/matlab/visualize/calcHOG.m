function [ feat gridX gridY] = calcHOG( img, ps, gs )
%Calculate the HOG feature of img.

%% Specify Parameters.

if ~exist('patchSize', 'var')
    patchSize = 16;
end

%% Calculation.

[im_h, im_w, ~] = size(img);

remX = mod(im_w-ps/2,gs);
offsetX = floor(remX/2)+1;
remY = mod(im_h-ps/2,gs);
offsetY = floor(remY/2)+1;
[gridX,gridY] = meshgrid(offsetX+ps/2:gs:im_w-ps/2+1, offsetY+ps/2:gs:im_h-ps/2+1);


featArr = features(double(img), patchSize);

%Convert featArr from 3d array to 2d array.
num_row = size(featArr, 1) * size(featArr, 2);
feat.feaArr = zeros(num_row, size(featArr, 3));

feat.feaArr = reshape(featArr, [num_row, size(featArr, 3)]);

feat.feaArr = single(feat.feaArr');
feat.x = [1 : size(feat.feaArr,2)];
feat.y = [1 : size(feat.feaArr,2)];

feat.width = im_w;
feat.height = im_h;

end

