function [] = show_patches(path, savepath, rot)
addpath(genpath('../deepnets_v2/CNN_toolbox'));

DIR  = dir(path);
DIR = DIR(3:end);
im = im2double(imread(fullfile(path, DIR(1).name)));
h = size(im,1);
w = size(im,2);
IM = zeros(h*w*3, length(DIR));
% IM = zeros(h*w, length(DIR));
for i = 1 : length(DIR)
    im = im2double(imread(fullfile(path, DIR(i).name)));
%     im = rgb2gray(imread(fullfile(path, DIR(i).name)));
    im = imresize(im, [h w]);
    if rot
        im = permute(im,[2 1 3]);
    end
    IM(:,i) = im(:);
end

clf
DeepBeliefNetwork.display_network_l1(IM,[],3);
% DeepBeliefNetwork.display_network_l1(IM);
saveas(gcf, savepath);
end