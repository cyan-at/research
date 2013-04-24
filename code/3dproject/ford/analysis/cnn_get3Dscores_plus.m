function [flag,scores] = cnn_get3Dscores_plus(data, bbox, encoder3D, model3D, siparam)
%CNN_GET3DSCORES given data and bounding box, get 3D scores inside
    flag = zeros(size(bbox,1),1);
    scores = zeros(size(bbox,1),1);
    for i = 1:size(bbox,1)
        bndbox = bbox(i,:);
        inside = findPointsIn(bndbox,data(:,1:2));
        inside = data(inside,:);
        pc = inside(:,6:8);
        if isempty(pc)
            flag(i) = -1;
            continue;
        end
        [~, scores(i)] = get3Dscore_plus(pc,inside,model3D,encoder3D,siparam);
    end
end

