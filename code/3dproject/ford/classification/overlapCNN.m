function [newDetections] = overlapCNN(objPath, results, PARAM, cnn )
%this function takes every bounding box and maps it back to 3D space
%specifically, finds all the labels in the directory
newDetections = [];
cams = catalogue(objPath,'mat','cam');
for i = 1:length(cams)
    close all;
    c = cell2mat(cams(i));
    disp(c);

    %get detections
    [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
    disp(y); %temp
    imgFile = strcat(objPath, '/cam',num2str(y),'.png');
    disp(imgFile);
    figure; imshow(imgFile);
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
    [idx,~] = find(results(:,6)==camindex);
    r = results(idx,[2:6,9:10]);
    [alert mapped] = distortDetections(r, PARAM(camindex));
%     if (~alert)
%         %fix up mapped
%         mapped(:,1:4) = mapped(:,1:4)/2;
%         %combine detection scores from ford and kitti
%         temp = mapped(:,1:5);
%         temp(:,6) = 0.5.*mapped(:,6) + 0.5.*mapped(:,7);
%         mapped = temp;
%     end
    
    %get cnn detections
    if (exist(cnn,'var'))
        [cidx,~] = find(cnn(:,5)==y);
        cnns = cnn(cidx,:);
        minX = min(cnns(:,1),cnns(:,3));
        maxX = max(cnns(:,1),cnns(:,3));
        minY = min(cnns(:,2),cnns(:,4));
        maxY = max(cnns(:,2),cnns(:,4));
        cnns(:,1:4) = [minX, minY, maxX, maxY];
    end

    %look for nesting within cnns
%     groups = checkNesting(cnns);
    %group is now a [bndbox cam combinedscore] n x 6 matrix
    %if we have detections to help here, we can use them
%     if (~isempty(mapped))
%         %create book keeping datastructure
%         action = zeros(size(groups,1),1);
%         replace = zeros(size(groups,1),1);
%         mapped = [min(mapped(:,1),mapped(:,3)),min(mapped(:,2),mapped(:,4)),max(mapped(:,1),mapped(:,3)),max(mapped(:,2),mapped(:,4)),mapped(:,5),mapped(:,6)];
%         %for every group, we check it against every detection
%         for g = 1:size(groups,1)
%             group = groups(g,:);
%             [o,p] = getOverlapDet(group,mapped,0.3);
%             action(g) = o;
%             replace(g) = p;
%             %o is the index of mapped that has overlap or isinside group
%             %if there is enough overlap or if one is inside the other, then we
%             %update action to be -1 (replace) and like to be that det
%         end
%         
%         %after everything, we go through the unique likes and update new
%         %first we eliminate all without underpinning cluster
%         [c,~] = find(action==-1);
%         groups(c,:) = [];
%         %after considering it, remove it
%         action(c,:) = [];
%         replace(c,:) = [];
%         
%         %then we go through all clusters that need replacement
%         [rep,~] = find(replace==1);
%         targets = action(rep,:);
%         groups(rep,:) = mapped(targets,:);
%         %after considering it, remove it
%         action(rep,:) = []; replace(rep,:) = [];
%         
%         %finally we go through all matrices that share clusters
% %         c = unique(action);
% %         for ic = length(c)
% %             [c2,~] = find(action==c(ic));
% %             temp = joinUp(groups,c2);
% %             groups(c2,:) = [];
% %             groups = [groups; temp];
% %             action(
% %         end
%     end    
%     new = groups;

    %for visualization
%     newcolors = repmat('y',1,size(new,1));
%     cnncolors = repmat('b',1,size(cnns,1));
%     bndcolors = repmat('r',1,size(mapped,1));
%     gtcolors = repmat('g',1,size(this,1));

    %just the bounding boxes
    bndcolors = repmat('r',1,size(mapped,1));
    combined = [mapped(:,1:4)];
    final = num2cell(combined,2);
    
    %temporary, load the undistorted (curved image)
    imgFile = strcat(objPath,'/image',num2str(camindex-1),'.ppm');
    disp(imgFile);
    img = imread(imgFile);
    img = imresize(img, [1232,1616]);
    img = imrotate(img, -90);
    img = flipdim(img,2);
    figure;
    showboxes_color(img,final,strcat(bndcolors));

%     %production code
%     showboxes_color(img,final,strcat(bndcolors,gtcolors,cnncolors));
%     figure;
%     final2 = num2cell([new(:,1:4)],2);
%     showboxes_color(img,final2,strcat(newcolors));
%     m = max(new(:,6));
%     new(:,6) = new(:,6)./m;
%     newDetections = [newDetections; new];
end
end

