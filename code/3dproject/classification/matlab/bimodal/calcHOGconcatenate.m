function [ feat ] = calcHOGconcatenate( img, patchSize, dim )
%Calculate the HOG feature of img.

%% Specify Parameters.

if ~exist('patchSize', 'var')
    patchSize = 16;
end

%% Calculation.

[im_h, im_w, ~] = size(img);

featArr = features(double(img), patchSize);

% remX = mod(im_w - 40/2, patchSize);
% offsetX = floor(remX / 2) + 1;
% remY = mod(im_h - 40/2, patchSize);
% offsetY = floor(remY / 2) + 1;



% feat.x = [1 : size(feat.feaArr,2)];
% feat.y = [1 : size(feat.feaArr,2)];

%Convert featArr from 3d array to 2d array.
num_row = size(featArr, 1) * size(featArr, 2);
%feat.feaArr = zeros(num_row, size(featArr, 3));
%feat.feaArr = reshape(featArr, [num_row, size(featArr, 3)]);

feat.feaArr = []; % 49 x 128
temp = reshape(featArr, [num_row, size(featArr, 3)]); %196 x 32
limit = num_row;

xcount = 0;
ycount = 0;
for i = 1:dim:size(featArr,1)
    %rows
    for j = 1:dim:size(featArr,2)
        %columns
        x = getIndexes2(i,j,size(featArr,1), size(featArr,2),dim);
        for k = x
            if k <= limit
                temp2 = temp(x,:)'; temp2 = temp2(:)';
                feat.feaArr = [feat.feaArr; temp2];
                ycount = ycount + 1;
            end
        end
    end
    xcount = xcount + 1;
end
ycount = ycount / xcount;

feat.feaArr = single(feat.feaArr'); %128*49
disp(size(feat.feaArr,1)); disp(size(feat.feaArr,2));

[feat.x feat.y] = meshgrid(1:ycount,1:xcount);
feat.x = feat.x(:);
feat.y = feat.y(:);
feat.width = ycount;
feat.height = xcount;
end