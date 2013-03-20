function [newDetections,punished,tightened] = overlapCNNv2(workingPath,cnn,PARAM,nesting,punish,coverage)
%load the points in distorted 2D space
allCords = getAllPoints(workingPath, 'r');
%allCords row: [u,v,distancegroup,actualrange,z,horz]
newDetections = [];
cams = catalogue(workingPath,'mat','cam');
allidx = 1:size(cnn,1);
considered = allidx*0;
punished = 0; tightened = 0;
for i = 1:length(cams)
%% overhead
    close all; c = cell2mat(cams(i));
    %get detections
    [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
    camindex = (y<4)*(4-y)+(y>3)*(9-y);
    %get cnn detections
    imgFile1 = strcat(workingPath, '/cam',num2str(y),'.png');
    cvprFile = strcat(workingPath, '/cvpr_ucm15_cam',num2str(y),'.mat');
    img1 = imread(imgFile1);
    [cidx,~] = find(cnn(:,5)==y);
    considered(cidx) = 1;
    cnns = cnn(cidx,:);
    minX = min(cnns(:,1),cnns(:,3));
    maxX = max(cnns(:,1),cnns(:,3));
    minY = min(cnns(:,2),cnns(:,4));
    maxY = max(cnns(:,2),cnns(:,4));
    cnns(:,1:4) = [minX, minY, maxX, maxY];
    %load up the points in this camera
    pidx = find(allCords(:,1)==camindex);
    points = allCords(pidx,2:3);
    points(:,1) = ceil(points(:,1)/2);
    points(:,2) = ceil(points(:,2)/2);
    points(:,3) = allCords(pidx,4);
    points(:,4) = allCords(pidx,5);
    points(:,5) = allCords(pidx,6);
    points(:,6) = allCords(pidx,7);
%% get segments
    inrange = points(:,1) >0 & points(:,2) >0;
    points = points(inrange,:);
    points(:,7) = getcvprLabels(points,cvprFile);
%% no points section and tightening section
    %penalize those with not enough points inside
    nopoints = [];
    haspoints = [];
    for j = 1:size(cnns,1)
        %for every cnn detection, collect up all the 3d points inside of it
        box = cnns(j,1:4);
        cropbox = [box(1), box(2), box(3)-box(1), box(4)-box(2)];
        patch = imcrop(img,cropbox);
        [label score] = get2Dscore(patch,model,encoder,parameters);
        
        [inside] = findPointsFor(box, points);
        %if there no points, then add this box to those to penalize
        if (isempty(inside))
            nopoints = [nopoints j];
        else
            haspoints = [haspoints j];
            %if there are points, then visualize the bounding box and
            %points
            insidepts = extractBndBoxUV(points(inside,:));
            coverage = boxoverlap(insidepts,cnns(j,1:4));
            if coverage
                %penalize the cnn's score for lower coverage, the lower the
                %coverage, the more the score is penalized
                if (cnns(j,6) - 0.6*(1-coverage) > 0)
                    cnns(j,6) = cnns(j,6) - 0.6*(1-coverage);
                else
                    cnns(j,6) = 0;
                end
            end
        end
    end
    if punish
        %penalize the scores of those with no points inside
        punished = punished + size(nopoints,1);
        cnns(nopoints,6) = 0;
    end

    newDetections = [newDetections; cnns];
end

%add the forgotten ones
fidx = find(considered==0);
forgotten = cnn(fidx,:);
newDetections = [newDetections; forgotten];

end

