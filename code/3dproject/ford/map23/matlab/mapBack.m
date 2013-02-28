function [ uvout, T ] = mapBack( uv, wh,  InverseFlag, ImageRotateFlag)
%IMAGECORD2VISIBLECORD Summary of this function goes here
% only for ford dataset
% w is visible image's width
% InverseFlag = 0 or none if imageCord -> VisibleCord
%   Detailed explanation goes here
if size(uv,1) < 2
    if size(uv,2) >= 2
        uv = uv';
    else
        disp('error dim, 8 in imageCord2VisibleCord');
    end
end
if ~exist('InverseFlag','var')
    InverseFlag = 0;
end
if isempty(InverseFlag)
    InverseFlag = 0;
end

% if ~exist('ImageRotateFlag','var')
%     ImageRotateFlag = true;
%     disp('warning imageCord2VisibleCord 24');
% end

if ImageRotateFlag
    T = [ 
        0 -1 wh(1)+1;
        1 0 0 ;
        0 0 1
        ];
else
    T =diag([1,1,1]);
end

if InverseFlag
    T = T^-1;
end

uvout = T * [uv; ones(1, size(uv,2))];
uvout = uvout(1:2, :);
%uvout = [wh(1) - uv(2,:); uv(1,:)];

end
