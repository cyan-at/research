function [newDetections] = overlapCNNv2(workingPath,cnn,PARAM)
%load the points in distorted 2D space
allCords = getAllPoints(workingPath, 'z');
%todo: switch this with getAllPointsv2
newDetections = [];
cams = catalogue(workingPath,'mat','cam');
scoresWeight = 0.1; nestingWeight = 0.1;
for i = 2:length(cams)
%% overhead
    close all;
    c = cell2mat(cams(i));
    %get detections
    [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
    switch y
        case 1
            camindex = 3;
        case 2
            camindex = 2;
        case 3
            camindex = 1;
        case 4
            camindex = 5;
        case 5
            camindex = 4;
    end
    %get cnn detections
    imgFile1 = strcat(workingPath, '/cam',num2str(y),'.png');
    img1 = imread(imgFile1);
    [cidx,~] = find(cnn(:,5)==y);
    cnns = cnn(cidx,:);
    minX = min(cnns(:,1),cnns(:,3));
    maxX = max(cnns(:,1),cnns(:,3));
    minY = min(cnns(:,2),cnns(:,4));
    maxY = max(cnns(:,2),cnns(:,4));
    cnns(:,1:4) = [minX, minY, maxX, maxY];
    %load up the points in this camera
    pidx = find(allCords(:,1)==camindex);
    points = allCords(pidx,2:3);
    points(:,1) = round(points(:,1)/2);
    points(:,2) = round(points(:,2)/2);
    
%% nesting section
    [~,nestings,scores] = checkNestingv2(cnns);
    %update the scores for cnns, the more nesting the better
    nested = find(nestings>0);
    %average out the scores for those that are inside of others
    scores(nested) = scores(nested) ./ nestings(nested);
    %improve the scores for those  nested inside of others
    %update with scores 
    cnns(:,6) = cnns(:,6) + scoresWeight*scores + nestingWeight * nestings;
    
%% no points section
%     %penalize those with not enough points inside
%     nopoints = [];
%     for j = 1:size(cnns,1)
%         %for every cnn detection, collect up all the 3d points inside of it
%         box = cnns(j,1:4);
%         [inside] = findPointsFor(box, points);
%         %if there no points, then add this box to those to penalize
%         if (isempty(inside))
%             nopoints = [nopoints, j];
%         end
%     end
%     %penalize the points scores by 1/2
%     cnns(nopoints,6) = cnns(nopoints,6)./2;
%     penalized = cnns;
    
%% todo: for detections with points inside, 'squeeze' the detections to get a better fit

%% todo: update with scores from proper/correct 3d segmentation results here
    
%% todo: update with scores from proper/correct 2d segmentation results
    
%% pack up response from this function
newDetections = [newDetections; cnns];

%% visualization code section for debugging, comment out after debuggin
%     nopointsCNN = cnns(nopoints,:);
%     %show the detections without points in red
%     nocolors = repmat('r',1,size(nopointsCNN,1));
%     
%     %take out the cnn detections with no points inside
%     haspoints = setdiff(1:size(cnns,1),nopoints);
%     haspointsCNN = cnns(haspoints,:);
%     %show the detections with points in cyan
%     hascolors = repmat('c',1,size(haspointsCNN,1));
%     
%     %collect up the bounding boxes and colors
%     final = [haspointsCNN(:,1:4);nopointsCNN(:,1:4)];
%     finalCell = num2cell(final,2);
%     finalColor = strcat(hascolors,nocolors);
%     
%     %show bounding boxes and colors
%     showboxes_color(img1,finalCell,finalColor);
%     %show the 3d point clouds in distorted space
%     hold on; scatter(points(:,1),points(:,2),2.5,'b');
end

end

