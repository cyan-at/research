researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath ./detection/
addpath ./cnn/
res_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch/results_afternms/';
workingRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
%get the map file
fid = fopen(strcat(res_dir,'map.txt'),'r');
map = textscan(fid,'%d %s', 'Delimiter', ' ');
idx = map{1}; scene = map{2};
fclose(fid);
%get all of the bndboxes
results = catalogue(res_dir,'txt','data');
for i = 1:length(results)
    r = cell2mat(results(i));
    rfid = fopen(r,'r');
    bndboxes = textscan(rfid,'%s %f', 'Delimiter', ' ');
    jpgs = bndboxes{1}; scores = bndboxes{2};
    for j = 1:length(jpgs); bb = [sscanf(cell2mat(jpgs(i)),'%d_%d_%d_%d')' scores(i)]; end
    [x,y,z] = fileparts(r);
    temp = strsplit(y,'_');
    mapID = cell2mat(temp(3));
    s = scene{mapID};
    fclose(rfid);
    %got the scene and cam
    %get the object, see if it is in test or train
    d = strsplit(s,'-'); obj = cell2mat(d(1)); cam = cell2mat(d(2));
    objnum = strsplit(obj,'obj');objnum = str2num(cell2mat(objnum(2)));
    camnum = strsplit(cam,'cam');camnum = str2num(cell2mat(camnum(2)));
    if (objnum >= 1673)
        prefix = 'test/';
    else
        prefix = 'train/';
    end
    p = strcat(workingRoot,prefix,obj,'/');
    
end
%     framenum = sscanf(d(j).name,'data_batch_%d_res.txt');
%     bbox = [];
%     for i=1:length(filename)
%         bb = sscanf(filename{i},'%d_%d_%d_%d');
%         bb = bb';
%         bb = [bb score(i)];
%         bbox = [bbox; bb];
%     end
%     z = mapTo{framenum}(1:7);
%     load(sprintf('%s/%s/%s.mat',root_mat,z,mapTo{framenum}(9:end)));
%      % apply nms
%     idx=nms(bbox,.5); 
%     bbox = bbox(idx,:);
%     bbox = bbox(bbox(:,5)>.5,:);
%     pred_bbox{j} = bbox;
%     gt(j) = obj_to_gt(obj);
%     
%     objDir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test/';
%     objDir = strcat(objDir,z,'/');
%     info = get3DbndboxesMap(objDir);
% 
%     saveboxes(img,bbox,gt(j).BB(~gt(j).diff,:));
% end
% 
