function [ laplacianStruct ] = constructLaplacian( imageName, depth )
    %Take the image and some arguments and construct the laplacian pyramid for
    %the image
    im = imread(imageName);
    im = double(im)/256;
    
end

