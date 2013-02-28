function [pred_bbox gt m acc] = parse_cnn_detection()
res_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch';
write_dir = fullfile(res_dir,'results_afternms');
if ~isdir(write_dir)
    mkdir(write_dir);
end
root_mat = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test';
d = dir(fullfile(res_dir,'/*_res.txt'));
addpath ./detection/
addpath ./cnn/
[id mapTo] = textread(fullfile(res_dir,'map.txt'), '%d %s');
for j=1:length(d)
    [filename score] = textread(fullfile(res_dir,d(j).name),'%s %f');
    framenum = sscanf(d(j).name,'data_batch_%d_res.txt');
    bbox = [];
    for i=1:length(filename)
        bb = sscanf(filename{i},'%d_%d_%d_%d');
        bb = bb';
        bb = [bb score(i)];
        bbox = [bbox; bb];
    end
    z = mapTo{framenum}(1:7);
    load(sprintf('%s/%s/%s.mat',root_mat,z,mapTo{framenum}(9:end)));
     % apply nms
    idx=nms(bbox,.5); 
    bbox = bbox(idx,:);
    bbox = bbox(bbox(:,5)>.5,:);
    pred_bbox{j} = bbox;
    gt(j) = obj_to_gt(obj);
    %saveboxes(img,bbox,gt(j).BB(~gt(j).diff,:));
end


function gt = bndbox_to_gt(bndbox)
min_size = [44 79]*1.2^(-2);
max_size = [44 79]*1.2^(3);
gt.BB = bndbox;
gt.diff = zeros(size(bndbox,1),1);
gt.det = zeros(size(bndbox,1),1);
for i=1:size(bndbox,1)
    cur_box = bndbox(i,:);
    width = cur_box(3)-cur_box(1);
    height = cur_box(4)-cur_box(2);
    if width < min_size(1) & height < min_size(2)
        gt.diff(i) = 1;
    end
end
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