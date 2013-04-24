function [posIdx, negIdx] = splitDataPosNeg(bbox,gt,threshold)
%SPLITDATAPOSNEG
    posIdx = [];
    negIdx = [];
    for i = 1:size(bbox,1)
        bndbox = bbox(i,:);
        o = boxoverlap(gt.BB,bndbox);
        [c,~] = max(o);
        if (c > threshold)
            posIdx = [posIdx,i];
        else
            negIdx = [negIdx,i];
        end
    end
end

