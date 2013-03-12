function [m ap] = compute_ap(detections,gt,overlap)
%get the total number of detections thus far
numGroundTruths = 0;
for i=1:length(detections)
    numGroundTruths = size(gt(i).BB,1)+numGroundTruths;
end
fprintf('number of ground truths found: %d\n',numGroundTruths);

%accumulate the bounding boxes and their origins
boundingboxes = [];
idx = 1;
for i=1:length(detections)
    if isempty(detections{i})
        continue;
    end
    %update sources, boundingboxes
    sources(idx:idx+size(detections{i},1)-1) = i;
    idx = idx+size(detections{i},1);
    boundingboxes = [boundingboxes; detections{i}];
end

%if is empty, then return nothings
if isempty(boundingboxes)
    ap = 0;
    m.rc = [];
    m.pc = [];
    return;
end

%split up the data
confidence = boundingboxes(:,5);
boundingboxes = boundingboxes(:,1:4);

% sort detections by decreasing confidence
[~,si]=sort(-confidence);
sources=sources(si);
boundingboxes=boundingboxes(si,:);
detectionsCount = length(confidence);

truepositives=zeros(detectionsCount,1);
falsepositives=zeros(detectionsCount,1);

for d=1:detectionsCount
    % find ground truth
    if isempty(gt(sources(d)).BB)
        falsepositives(d) = 1;
        continue;
    end
    o = boxoverlap(gt(sources(d)).BB,boundingboxes(d,:));
    [omax,~] = max(o);
    if omax > overlap
        %if overlap, and detected, then = 1
        truepositives(d) = 1;
    else
        %if no overlap, and detected, false positive
        falsepositives(d) =1;
    end
end
%false negatives detected = 0, bounding box = 1
sfp=cumsum(falsepositives);
stp=cumsum(truepositives);

m.rc=stp./(numGroundTruths);
m.pc=stp./(sfp+stp);

%compute ap section
ap=0;
for t=0:0.05:1
    p=max(m.pc(m.rc>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/21;
end
m.ap = ap;
end