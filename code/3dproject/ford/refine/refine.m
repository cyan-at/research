function [ newDetections, results ] = refine( workingPath, cnn, classifier2D, classifier3D,parameters)
if (isempty(cnn))
    return;
end

%overhead
newDetections = [];
results = struct();
cams = catalogue(workingPath,'mat','cam');
allidx = 1:size(cnn,1);
considered = allidx*0;

%get all points
allCords = getAllPoints(workingPath, 'r');

%grab the ground truths
% groundTruths = grabGroundTruths(workingPath);
%groundTruths will be n x 6 of cam bndbox difficult

for i = 2:length(cams)
    %overhead
    close all; c = cell2mat(cams(i));
    [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
    camindex = (y<4)*(4-y)+(y>3)*(9-y);
    imgFile1 = strcat(workingPath, '/cam',num2str(y),'.png');
    cvprFile = strcat(workingPath, '/cvpr_cam',num2str(y),'.mat');
    img = imread(imgFile1);
    
    %get cvpr detection if possible
    cvprdetectionfile = strcat(workingPath,'/cvprdetection_cam',num2str(y),'.png');
    if (exist(cvprdetectionfile,'file'))
        %replace all cnn detections with cvpr detection
        cvprDetections = getCVPRDetections(cvprdetectionfile);
        newDetections = [newDetections; cvprDetections];
        continue;
    end
    
    %get cnns
    [cidx,~] = find(cnn(:,5)==y);
    considered(cidx) = 1;
    cnns = cnn(cidx,:);
    minX = min(cnns(:,1),cnns(:,3));
    maxX = max(cnns(:,1),cnns(:,3));
    minY = min(cnns(:,2),cnns(:,4));
    maxY = max(cnns(:,2),cnns(:,4));
    cnns(:,1:4) = [minX, minY, maxX, maxY];
    %cnns is n x 7, with bndbox, cam, score, group
    
    %load up the points in this camera
    points = allCords(allCords(:,1)==camindex,2:7);
    points(:,1) = ceil(points(:,1)/2);
    points(:,2) = ceil(points(:,2)/2);
    
    for j = 1:size(cnns,1)
        c = cnns(j,:);
        [inside] = findPointsFor(c(1:4), points);
        if (isempty(inside) || size(inside,1) < 50)
            %harshly punish this score
            cnns(j,6) = 0;
        else
            cropbox = [c(1), c(2), c(3)-c(1), c(4)-c(2)];
            patch = imcrop(img,cropbox);
            p = points(inside,:);
            range = p(:,4);
            z = p(:,5);
            horz = p(:,6);
            pointcloud = []; %range is the x dimension
            [score2D, ~] = classifyPatch(patch,pointcloud,classifier2D,classifier3D,parameters);
            
            %hack
            if (score2D == 0)
                cnns(j,6) = 0;
            else
                cnns(j,6) = cnns(j,6) + score2D;
            end
            
        end
    end
    newDetections = [newDetections; cnns];
end
end

