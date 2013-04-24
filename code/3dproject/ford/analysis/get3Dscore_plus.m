function [label, score] = get3Dscore_plus(pc,meta,model,encoder,parameters)
%pc must be n x 3
imgW = parameters.imgW;
radius = parameters.radius;
minN = parameters.minN;
%compute spinimage on p
feaArr = compSpinImages(pc, parameters.radius, parameters.imgW, parameters.minN);
feaArr = reshape(feaArr,imgW*imgW,size(pc,1));
feat.feaArr = single(feaArr);
feat.width = size(feaArr,2);
feat.height = size(feaArr,2);
feat.x = 1:size(feaArr,2);
feat.y = 1:size(feaArr,2);
feat.meta = meta;
% save(matFileName,'feat');
% then do pooling
pool = new3D_pooling_plus(feat, encoder, parameters);
[label, ~, score] = predict(1, sparse(pool), model, [], 'col');
end