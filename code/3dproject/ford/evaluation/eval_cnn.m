function [m acc] = eval_cnn(pred_bbox,gt,overlap,opt)

% gt_bbox is an array of struct containing BB, diff, det

if strcmp(opt,'ap')
    [m acc] = compute_ap(pred_bbox,gt,overlap);
elseif strcmp(opt,'fppi')
    [m acc] = compute_fppi(pred_bbox,gt,overlap);
else
    error('undefined opt')
end

function [m ap] = compute_ap(pred_bbox,gt,overlap)
npos = 0;
for i=1:length(pred_bbox)
    npos = size(gt(i).BB,1)+npos;
end
BB = [];
% ids = zeros(length(pred_bbox),1);
idx = 1;
for i=1:length(pred_bbox)
    if isempty(pred_bbox{i})
        continue;
    end
    ids(idx:idx+size(pred_bbox{i},1)-1) = i;
    idx = idx+size(pred_bbox{i},1);
    BB = [BB; pred_bbox{i}];
end
if isempty(BB)
    ap = 0;
    m.rc = [];
    m.pc = [];
    return;
end
confidence = BB(:,5);
BB = BB(:,1:4);

% sort detections by decreasing confidence
[~,si]=sort(-confidence);
ids=ids(si);
BB=BB(si,:);

nd = length(confidence);

tp=zeros(nd,1);
fp=zeros(nd,1);
for d=1:nd
    
    % find ground truth
    if isempty(gt(ids(d)).BB)
        fp(d) = 1;
        continue;
    end
    
    o = boxoverlap(gt(ids(d)).BB,BB(d,:));
    [omax,oi] = max(o);
    
    if omax > overlap
        if ~gt(ids(d)).diff(oi)
            if ~gt(ids(d)).det(oi)
                tp(d)=1;            % true positive
                gt(ids(d)).det(oi)=true;
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
    
end

sfp=cumsum(fp);
stp=cumsum(tp);
m.rc=stp/npos;
m.pc=stp./(sfp+stp);

ap=0;
for t=0:0.05:1
    p=max(m.pc(m.rc>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/21;
end
% ap = trapz(m.rc,m.pc);
m.ap = ap;