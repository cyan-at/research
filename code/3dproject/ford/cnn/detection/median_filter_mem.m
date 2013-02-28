function [fg mask] = median_filter_mem(data, bg, threshold)
%for limited memory
fg = zeros(size(data));
mask = zeros(size(data,1), size(data,2), size(data,4));

%data : width * height * rgb * frames

for i = 1  :  size(data,4)
    tmp = data(:,:,:,i);

    mask_curr = (abs(rgb2gray(data(:,:,:,i)/255) - rgb2gray(bg/255)) - threshold) > 0;
    mask(:,:,i)  = mask_curr;       

    mask_curr = repmat(mask_curr, [1, 1, 3]);
    tmp(~mask_curr) = 0;    
    fg(:,:,:,i) = tmp;
end



end