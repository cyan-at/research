function [fg bg mask] = median_filter(data, buffer_size, threshold)
fg = zeros(size(data));
bg = zeros(size(data));

mask = zeros(size(data,1), size(data,2), size(data,4));

%data : width * height * rgb * frames
if 2*buffer_size + 1 > size(data,4)
    error('buffer_size too large')
end

for i = 1 : size(data,4)
    buffer = [i-buffer_size : i+buffer_size];
    less_than = nnz(buffer < 1);
    if less_than > 0
        buffer = [buffer(less_than+1:end), buffer(end)+1 : buffer(end)+less_than];
    end
    
    more_than = nnz(buffer > size(data,4));
    if more_than > 0
        buffer = [buffer(1)-more_than : buffer(1)-1, buffer(1:end-more_than)];
    end
    %not efficient, must change
%     tic
        if i ~= 1
           if nnz(old_buffer ~= buffer ) ~= 0               
               %assume only move 1
               bg(:,:,:,i) = old_mean + ( data(:,:,:,buffer(end)) - data(:,:,:,old_buffer(1)) )/length(buffer);
               old_mean = bg(:,:,:,i);               
           else
                bg(:,:,:,i) = old_mean;                
           end
        else
            bg(:,:,:,i) = mean(data(:,:,:,buffer),4);
            old_mean = bg(:,:,:,i);
        end
%     toc
       
    tmp = data(:,:,:,i);
    
    mask_curr = (abs(rgb2gray(data(:,:,:,i)/255) - rgb2gray(bg(:,:,:,i)/255)) - threshold) > 0;
    mask(:,:,i)  = mask_curr;       
        
    mask_curr = repmat(mask_curr, [1, 1, 3]);
    tmp(~mask_curr) = 0;    
    fg(:,:,:,i) = tmp;
    
    old_buffer = buffer;    
end


end