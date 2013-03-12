function [rec,prec,ap] = evalDetection(detDir,root,threshold)
d = dir(fullfile(detDir,'/*_res.txt'));
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/
[id mapTo] = textread(fullfile(detDir,'map.txt'), '%d %s');
frames = zeros(length(id),1);

totalbboxesfound = 0;
for j=length(d):-1:1
    [filename score] = textread(fullfile(detDir,d(j).name),'%s %f');
    framenum = sscanf(d(j).name,'data_batch_%d_res.txt');
    bbox = [];
    for i=1:length(filename)
        bb = sscanf(filename{i},'%d_%d_%d_%d');
        bb = bb';
        bb = [bb score(i)];
        bbox = [bbox; bb];
    end
    dashIdx = findstr(mapTo{framenum},'-');
    target = sprintf('%s/%s/%s.mat',root,mapTo{framenum}(1:dashIdx-1),mapTo{framenum}(dashIdx+1:end));
    load(target);
    gt(j) = obj_to_gt(obj);
    
    idx=nms(bbox,.5);  % apply nms
    bbox = bbox(idx,:);
    
    totalbboxesfound = totalbboxesfound + length(idx);
    pred_bbox{j} = bbox;
end
fprintf('bounding boxes found: %d\n', totalbboxesfound);

[m ~] = compute_ap(pred_bbox,gt,threshold);
ap = m.ap; rec = m.rc; prec = m.pc;
