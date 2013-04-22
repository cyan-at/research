function [cnnDetections] = grabCNN2(idx, scene, res_dir, obj)
%cnnDetections will be a matrix of [bndbox cam group]
cnnDetections = [];
c = strmatch(obj,scene);
i = idx(c);
for j = 1:length(i)
    dataFile = strcat(res_dir,'data_batch_',num2str(i(j)),'_res.txt');
    cam = strsplit(cell2mat(scene(i(j))),'cam'); cam = cell2mat(cam(2)); cam = str2num(cam);
    fid = fopen(dataFile,'r');
    detections = textscan(fid,'%s %f %f', 'Delimiter', ' ');
    scores = detections{2};
    groups = detections{3};
    detections = detections{1};
    for k = 1:length(detections)
        temp = cell2mat(detections(k));
        score = scores(k);
        group = groups(k);
        x = strsplit(temp,'.'); 
        x = cell2mat(x(1)); 
        x = strsplit(x,'_'); 
        x1 = str2num(cell2mat(x(1))); 
        x2 = str2num(cell2mat(x(2))); 
        x3 = str2num(cell2mat(x(3))); 
        x4 = str2num(cell2mat(x(4)));
        x = [x1 x2 x3 x4];
        temp = [x cam score group];
        cnnDetections = [cnnDetections; temp];
    end
    fclose(fid);
end
end