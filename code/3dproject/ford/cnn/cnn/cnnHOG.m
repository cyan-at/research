function [ feat ] = cnnHOG( img, patchSize )
%Calculate the HOG feature of img.

%% Specify Parameters.

if ~exist('patchSize', 'var')
    patchSize = 16;
end

%% Calculation.

feat = features(double(img), patchSize);

% [im_h, im_w, ~] = size(img);

% featArr = features(double(img), patchSize);

% [feat.x feat.y] = meshgrid(1:size(featArr,1),1:size(featArr,2));
% feat.width = size(featArr,1);
% feat.height = size(featArr,2);
% 
% feat.x = feat.x(:);
% feat.y = feat.y(:);
% % feat.x = [1 : size(feat.feaArr,2)];
% % feat.y = [1 : size(feat.feaArr,2)];
% 
% %Convert featArr from 3d array to 2d array.
% num_row = size(featArr, 1) * size(featArr, 2);
% feat.feaArr = zeros(num_row, size(featArr, 3));
% 
% feat.feaArr = reshape(featArr, [num_row, size(featArr, 3)]);
% 
% feat.feaArr = single(feat.feaArr');
% feat.x = [1 : size(feat.feaArr,2)];
% feat.y = [1 : size(feat.feaArr,2)];


end


