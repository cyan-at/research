function [recall precision] = car_detect_frame_verif(det_model,svm_model,Unsup,method,database,savepath,measure,write,pyramid,thresh)
addpath(genpath('../recognition'));
addpath ../utils/

det_model.thresh = thresh;
if exist('savepath','var') == 0
    savepath = sprintf('/mnt/neocortex/scratch/norrathe/data/car_detection/thresh%g',det_model.thresh);
end
if ~isempty(savepath) & exist(savepath,'dir') == 0
    mkdir(savepath);
end
if ~exist('measure','var')
    measure = 0;
end
if ~exist('write','var')
    write = 0;
end
idx = 1;
total_detection = 0;
total_pos = 0;
total_correct = 0;
boxes1 = cell(database.nframe,5);
gt(database.nframe)=struct('BB',[],'diff',[],'det',[]);
BB = [];
npos = 0;
confidence = [];
ids = [];

for i=1:database.nframe
    fprintf('[%d/%d] ',i,database.nframe);
    load(database.path{i});
    [dets, boxes] = imgdetect(img, det_model, det_model.thresh);
    if ~isempty(boxes)
        boxes = reduceboxes(det_model, boxes);
        [dets boxes] = clipboxes(img, dets, boxes);
        I = nms(dets, 0.5);
        boxes1{i} = dets(I,[1:4 end]);
        parts1{i} = boxes(I,:);
    else
        boxes1{i} = [];
        parts1{i} = [];
    end
    box = boxes1{i};
    b4_box = box;
    box = verification(img,box,svm_model,Unsup,method,pyramid);
    if isempty(box)
        continue;
    end
    
    BB = [BB; box(:,1:4)];
    confidence = [confidence; box(:,end)];
    ids = [ids; i*ones(size(box,1),1)];
    
    diff = zeros(length(obj),1);
    gt_bbox = zeros(length(obj),4);
    for n=1:length(obj)
        gt_bbox(n,:) = obj(n).bndbox;
        if isempty(obj(n).difficult) | obj(n).difficult == 0
            diff(n) = 0;
        else
            diff(n) = 1;
        end
    end
    gt(i).BB = gt_bbox';
    gt(i).diff = diff;
    gt(i).det = false(length(obj),1);
    npos = npos+sum(~gt(i).diff);
    
%     figure(1)
%     showboxes(im,box);
%     saveas(gcf,fullfile('/mnt/neocortex/scratch/3dproject/data/detected_frames2/',database.imname{i}),'jpg');
    
%     for m=1:size(box,1)
%         box(m,1) = max(1,floor(box(m,1)));
%         box(m,2) = max(1,floor(box(m,2)));
%         box(m,4) = min(size(img,1),floor(box(m,4)));
%         box(m,3) = min(size(img,2),floor(box(m,3)));
%         
%         b4_box(m,1) = max(1,floor(b4_box(m,1)));
%         b4_box(m,2) = max(1,floor(b4_box(m,2)));
%         b4_box(m,4) = min(size(img,1),floor(b4_box(m,4)));
%         b4_box(m,3) = min(size(img,2),floor(b4_box(m,3)));
%     end
    
%     if measure
%         [n_det n_pos n_cor_det gt_box] = detection_perform(box,obj);
%         total_detection = total_detection+n_det;
%         total_pos = total_pos+n_pos;
%         total_correct = total_correct+n_cor_det;
%     end
    
    if write
%         [~, name, ~] = fileparts(database.path{i});
%         savename = sprintf('%s/det_%s_before.jpg',savepath,name);
%         saveboxes(img,b4_box,gt_box,savename);
%         savename = sprintf('%s/det_%s_after.jpg',savepath,name);
%         saveboxes(img,box,gt_box,savename);
    end
    
%     if total_detection == 0
% %         precision = 1;
%     else
%         precision = total_correct/total_detection
%     end
%     recall = total_correct/total_pos
end

ap = eval_dets(BB',confidence,gt,1,ids,npos);
% fprintf('\n');
% precision = total_correct/total_detection
% recall = total_correct/total_pos
% total_pos
    
function vbox = verification(img,box,svm_model,Unsup,method,pyramid)
vbox = [];
box = floor(box);
for i=1:size(box,1)
    patch = img(box(i,2):box(i,4),box(i,1):box(i,3),:);
    fea = pooling_feature(patch,Unsup,pyramid,method);
    curdir = pwd;
    cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
    pred = predict(0, sparse(fea), svm_model, [], 'col');
    % assume pred = 1 == car
    if pred
       vbox = [vbox; box(i,:)];
    end
    cd(curdir);    
end

function [n_det n_pos n_cor_det gt_bbox] = detection_perform(box,obj)
    gt_bbox = [];
    diff_bbox = [];
    n_pos = 0;
    n_det = size(box,1);
    n_cor_det = 0;
    
    for n=1:length(obj)
        if obj(n).difficult
            diff_bbox(end+1,:) = obj(n).bndbox;
        else
            n_pos = n_pos+1;
            gt_bbox(end+1,:) = obj(n).bndbox;
        end
    end
    if ~isempty(box)
        for b = 1:n_pos
            if ~isempty(gt_bbox)
                overlaps = boxoverlap(box, gt_bbox(b,:));
                if sum(overlaps > 0.5) > 0
                    n_cor_det = n_cor_det + 1;
                end
            end
        end   
        for b = 1:size(diff_bbox,1)
            
            overlaps_diff = boxoverlap(box, diff_bbox(b,:));
            if sum(overlaps_diff > 0.5) > 0
                n_det = n_det - 1;
            end
        end
    end
    