function gt = obj_to_gt(obj)
bbox = [];
diff = [];
for i=1:length(obj)
    bbox = [bbox; obj(i).bndbox];
    if ~isempty(obj(i).truncated) && obj(i).truncated
        diff = [diff; 1];
    elseif isempty(obj(i).difficult)
        diff = [diff; 0];
    else
        diff = [diff; obj(i).difficult];
    end
end
det = zeros(length(diff),1);
gt.BB = bbox;
gt.diff = diff;
gt.det = det;
end