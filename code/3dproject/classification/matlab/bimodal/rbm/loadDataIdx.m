function [imidx_batch num_iter] = loadDataIdx(cuimg, pars)

% same number of images per class
imidx_batch = randsample([1:cuimg(1)],pars.num_images,cuimg(1)<pars.num_images);
for i = 1:length(pars.classes)-1
    imidx_batch = [imidx_batch randsample([cuimg(i)+1:cuimg(i+1)],pars.num_images,length([cuimg(i)+1:cuimg(i+1)])<pars.num_images)];
end
imidx_batch = randsample(imidx_batch,length(imidx_batch));
num_iter = length(imidx_batch);
