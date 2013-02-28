function [ap recall precision] = car_detect_frame(model,database,savepath,measure,write,thresh)

model.thresh = thresh;
if exist('savepath','var') == 0
    savepath = sprintf('/mnt/neocortex/scratch/norrathe/data/car_detection/thresh%g',model.thresh);
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
    
    [dets, boxes] = imgdetect(img, model, model.thresh);
    if ~isempty(boxes)
        boxes = reduceboxes(model, boxes);
        [dets boxes] = clipboxes(img, dets, boxes);
        I = nms(dets, 0.5);
        boxes1{i} = dets(I,[1:4 end]);
        parts1{i} = boxes(I,:);
    else
        boxes1{i} = [];
        parts1{i} = [];
    end
    box = boxes1{i};
    if isempty(box)
        continue;
    end
    BB = [BB; box(:,1:4)];
    confidence = [confidence; box(:,end)];
    ids = [ids; i*ones(size(box,1),1)];
    

    
%     figure(1)
%     showboxes(im,box);
%     saveas(gcf,fullfile('/mnt/neocortex/scratch/3dproject/data/detected_frames2/',database.imname{i}),'jpg');
    
%     for m=1:size(box,1)
%         box(m,1) = max(1,floor(box(m,1)));    
%         box(m,2) = max(1,floor(box(m,2)));
%         box(m,4) = min(size(img,1),floor(box(m,4)));
%         box(m,3) = min(size(img,2),floor(box(m,3)));
%     end
    
%     if measure
%         [n_det n_pos n_cor_det gt_box] = detection_perform(box,obj);
%         total_detection = total_detection+n_det;
%         total_pos = total_pos+n_pos;
%         total_correct = total_correct+n_cor_det;
%     end
    
    if write
%         [~, name, ~] = fileparts(database.path{i});
%         savename = sprintf('%s/det_%s.jpg',savepath,name);
%         saveboxes(img,box,gt_box,savename);
    end
    
%     if total_detection == 0
% %         precision = 1;
%     else
%         precision = total_correct/total_detection
%     end
%     recall = total_correct/total_pos
end

[ap precision recall] = eval_dets(BB',confidence,gt,0,ids,npos);


fprintf('\n');
% precision = total_correct/total_detection
% recall = total_correct/total_pos
% total_pos

function [ap prec rec] = eval_dets(BB,confidence,gt,draw,ids,npos)

% sort detections by decreasing confidence
[sc,si]=sort(-confidence);
ids=ids(si);
BB=BB(:,si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
cls = 'car';
for d=1:nd
    % display progress
    if toc>1
        fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
        drawnow;
        tic;
    end
    
    % find ground truth image
	disp(d);
	disp(ids(d));
    i=ids(d);
    if isempty(i)
        error('unrecognized image "%s"',ids(d));
    elseif length(i)>1
        error('multiple image "%s"',ids(d));
    end

    % assign detection to ground truth object if any
    bb=BB(:,d);
    ovmax=-inf;
    for j=1:size(gt(i).BB,2)
        bbgt=gt(i).BB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 & ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax>=.5
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
                gt(i).det(jmax)=true;
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
end

disp('saving vars now');
save('fpvars','fp');
save('tpvars','tp');
% compute precision/recall
fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/npos;
prec=tp./(fp+tp);
save('gt_matrix','gt');

% compute average precision

ap=0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end

if draw
    fprintf('\n Kri - - VOCevaldet drawing the curve ------------------------------------------------------------------- \n')
    % plot precision/recall
    plot(rec,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %s, AP = %.3f',cls,ap));
end
    

function [n_det n_pos n_cor_det gt_bbox] = detection_perform(box,obj)
    gt_bbox = [];
    diff_box = [];
    n_pos = 0;
    n_det = size(box,1);
    n_cor_det = 0;
    for n=1:length(obj)
        if obj(n).difficult
            diff_box(end+1,:) = obj(n).bndbox;
        else
            n_pos = n_pos+1;
            gt_bbox(end+1,:) = obj(n).bndbox;
        end
    end
    if n_det == 0
        return;
    end
    for i=1:n_det
        if ~isempty(diff_box) & sum(boxoverlap(diff_box,box(i,:))>.5) >= 1
            n_det = n_det-1;
        elseif ~isempty(gt_bbox) & sum(boxoverlap(gt_bbox,box(i,:))>.5) >= 1 & sum(boxoverlap(box,box(i,:))>.5) == 1
            n_cor_det = n_cor_det+1;
        end
    end
return;
    