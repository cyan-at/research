function [newDetections,punished] = overlapCNNv2(workingPath,cnn,PARAM,nesting,punish,coverage)
%load the points in distorted 2D space
allCords = getAllPoints(workingPath, 'r');
%allCords row: [u,v,distancegroup,actualrange,z,horz]
newDetections = [];
cams = catalogue(workingPath,'mat','cam');
scoresWeight = 0.01; nestingWeight = 0.01;
allidx = 1:size(cnn,1);
considered = allidx*0;
punished = 0;
for i = 1:length(cams)
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
    cvprFile = strcat(workingPath, '/cvpr_cam',num2str(y),'.mat');
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
    %todo: do clustering here and add cluster id to points
    inrange = points(:,1) >0 & points(:,2) >0;
    points = points(inrange,:);
    points(:,7) = getcvprLabels(points,cvprFile,img1);
    
%     imshow(img1); grid on; axis on; hold on;
%     scatter(points(:,1),points(:,2),5,10*points(:,7));
    
%     %points will be [camindex,u,v,range] where range is depth from 1 to 50
%     %look for a depth map for the image (mat file of depth_camx.mat in the
%     %scene directory, if it does not exit then make one
%     depthMapFile = strcat(workingPath,'/depth_cam',num2str(y),'.mat');
%     if (~exist(depthMapFile,'file'))
%         disp('generating depth map');
%         %depth map will be a mat file with depth struct
%         generateDepthMap(points,depthMapFile);
%     end
    
%% nesting section
    if nesting
        [~,nestings,scores] = checkNestingv2(cnns);
        %update the scores for cnns, the more nesting the better
        nested = find(nestings>0);
        %average out the scores for those that are inside of others
        scores(nested) = scores(nested) ./ nestings(nested);
        %improve the scores for those  nested inside of others
        %update with scores
        cnns(:,6) = cnns(:,6) + scoresWeight*scores + nestingWeight * nestings;
    end
        
%% no points section and tightening section
    %penalize those with not enough points inside
    nopoints = [];
    haspoints = [];
    for j = 1:size(cnns,1)
        %for every cnn detection, collect up all the 3d points inside of it
        box = cnns(j,1:4);
        [inside] = findPointsFor(box, points);
        %if there no points, then add this box to those to penalize
        if (isempty(inside))
            nopoints = [nopoints, j];
        else
            %%check for coverage
            if coverage
                %collect up the bounding boxes and colors
                
%                 final = box(:,1:4);
%                 finalCell = num2cell(final,2);
%                 finalColor = 'c';
%                 showboxes_color(img1,finalCell,finalColor); hold on; grid on;
                
                match = points(inside,:);
                %grabPoints(match);
%                 scatter(match(:,1),match(:,2),5,10*match(:,7));
                
%                 %check for tightening
%                 %otherwise, get the points inside of
                cvprlabels = points(inside,7);
                label = mode(cvprlabels);
                match = match(find(match(:,7)==label),:);
                match2 = points(find(points(:,7)==label),:);
                grabPoints(match2);
%                 scatter(match(:,1),match(:,2),5,10*match(:,7));

                %if the inside captures enough points of the entire, then
                %tighten
                ratio = size(match,1)/size(match2,1);
%                 disp(ratio);
                if (ratio > 0.8)
                    %tighten: get the bounding box for the match2, and
                    %replace the bounding box with the bounding box for the
                    %entire object
                    [ bndbox ] = extractBndBoxUV(match2);
                    %update the bounding box for box
                    cnns(j,1:4) = bndbox;
                    %todo: improve the score for cnns(j) more intelligently
                    cnns(j,6) = cnns(j,6) + 0.1;
                end
%                 final = [bndbox(:,1:4);box(:,1:4)];
%                 finalCell = num2cell(final,2);
%                 oldc = repmat('c',1,size(box,1));
%                 newc = repmat('y',1,size(bndbox,1));
%                 finalColor = strcat(oldc,newc);
%                 showboxes_color(img1,finalCell,finalColor);
                
%                 %todo: get points for match, run classification
%                 haspoints = [haspoints, j];
            end
        end
    end
    
    if punish
        %penalize the scores of those with no points inside
        punished = punished + size(nopoints,1);
        cnns(nopoints,6) = 0; %cnns(nopoints,6)./2;
    end
    
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
%     imshow(img1); grid on; axis on; hold on;
%     for q = 1:size(points,1)
%         scatter(points(q,1),points(q,2),2.5,points(q,7));
%     end
end

%add the forgotten ones
fidx = find(considered==0);
forgotten = cnn(fidx,:);
newDetections = [newDetections; forgotten];

end

