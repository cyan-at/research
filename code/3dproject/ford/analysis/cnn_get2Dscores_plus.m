function [ scores ] = cnn_get2Dscores_plus( img,bbox,encoder2D,model2D,hogparam )
%CNN_GET2DSCORES_PLUS Summary of this function goes here
    scores = zeros(size(bbox,1),1);
    for i = 1:size(bbox,1)
        bndbox = bbox(i,:);
        patch = imcrop(img,[bndbox(1),bndbox(2),abs(bndbox(1)-bndbox(3)),abs(bndbox(2)-bndbox(4))]);
        [~,scores(i)] = get2Dscore(patch,model2D,encoder2D,hogparam);
    end
end

