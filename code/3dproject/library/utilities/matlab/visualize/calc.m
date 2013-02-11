load('imgobj.mat');
C = imresize(imgobj, [256 256]);
ps = 14;
[hog x y] = HOG(C, ps);
numpatches = size(hog, 1)/32;
hog = reshape(hog, [32 numpatches]);

[im_h, im_w, ~] = size(C);

imshow(C);
