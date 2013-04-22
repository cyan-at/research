function featureSize = calcSI(matName, savepath,obj,radius,imgW,minN)
%expects it in 3 X N
[~, matName, ~] = fileparts(matName);
fprintf('Processing spinImages: %s.mat (%d objs)\n',matName, length(obj));
featureSize = size(zeros(imgW*imgW, 1));
for i=1:length(obj)
    feapath = sprintf('%s/%s_%.2d.mat',savepath,matName,i);
    if isfield(obj(i),'difficult') & obj(i).difficult
        continue;
    end

    if (isempty(obj(i).pointcloud))
        continue;
    end
    try
        load(feapath)
    catch
        feaArr = compSI(obj(i).pointcloud', radius, imgW, minN); 
        feaArr = reshape(feaArr,imgW*imgW,size(obj(i).pointcloud,2));
        feat.feaArr = single(feaArr);
        feat.width = size(feaArr,2);
        feat.height = size(feaArr,2);
        feat.x = [1:size(feaArr,2)];
        feat.y = [1:size(feaArr,2)];
        feat.meta = obj.meta; %save meta data
        save(feapath,'feat');
    end
    featureSize = size(feat.feaArr);
end
end