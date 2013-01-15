function [uv, index] = getValidUV(original, imsize)
%imsize, we expect this to be 2048 x 2048
%so anything that falls into 1 to 2048 and 1 to 2048 is valid, otherwise
%reject
%we also expect original to be n x 2 matrix of proposed coordinates
index = original(:,1) > 1 & original(:,1) < imsize(1) & original(:,2) > 1 & original(:,2) < imsize(2);
uv = original(index,:);
end