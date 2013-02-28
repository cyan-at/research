function [ lbls, overlaps, total, found, totalclusters] = getOverlaps(objPath, results, PARAM )
%this function takes every bounding box and maps it back to 3D space
%specifically, finds all the labels in the directory
cams = catalogue(objPath,'mat','cam');
overlaps = [];
lbls = [];
total = 0;
found = 0;
totalclusters = 0;
for i = 1:length(cams)
    c = cell2mat(cams(i));
    %get the ground truth
    this = [];
    load(c);
    for j = 1:length(obj)
        this = [this;[obj(j).bndbox(1), obj(j).bndbox(2), obj(j).bndbox(3), obj(j).bndbox(4)]];
    end
    
    %get detections
    [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
    %find all clusters in that camera
    %cam is the num where handlabels are, but not the ones in cluster
    %image0 = cam3, image1 = cam2, image2 = cam1, image3 = cam5, image4
    %= cam4
    y = 5-y+1;
    switch y
        case 1
            camindex = 2;
        case 2
            camindex = 1;
        case 3
            camindex = 0;
        case 4
            camindex = 4;
        case 5
            camindex = 3;
    end
    [idx,~] = find(results(:,6)==camindex+1);
    r = results(idx,2:5);
    [alert mapped] = mapResults2(r, PARAM(camindex+1));
    if (alert)
        continue;
    end
    mapped = mapped/2;

    bndcolors = repmat('b',1,size(mapped,1));
    gtcolors = repmat('g',1,size(this,1));
    
    %get intersections
    intersections = [];
    for det = 1:size(mapped,1)
        %compute amount of overlap
        minX = min(mapped(det,1),mapped(det,3));
        maxX = max(mapped(det,1),mapped(det,3));
        minY = min(mapped(det,2),mapped(det,4));
        maxY = max(mapped(det,2),mapped(det,4));
        box = [minX, minY, maxX, maxY];
        amt = boxoverlap(this, box);
        [m,q] = max(amt);
        if (m > 0.25)
%             disp('found!');
            intersections = [intersections; mapped(det,:)];
        end
    end
    
%     combined = [this; intersections];
%     bndcolors = repmat('r',1,size(intersections,1));
%     final = num2cell(combined,2);
%     showboxes_color(img,final,strcat(gtcolors,bndcolors));
    
    intersections = [intersections, repmat(y,size(intersections,1),1)];
    overlaps = [overlaps; intersections];
    this = [this, repmat(y,size(this,1),1)];
    lbls = [lbls; this];
    
    total = total + size(this,1);
    found = found + size(intersections,1);
    totalclusters = totalclusters + size(mapped,1);
end

end

