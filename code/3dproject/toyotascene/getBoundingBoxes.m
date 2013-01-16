loadPaths;
addpath(genpath('/home/charlie/Desktop/research/code/utilities/matlab/splitDataSet/'));
objPath = '/home/charlie/Desktop/data/mat/';
threshold = 0.12; %another hyperparameter
mvPrefix = 'mv %s %s';
for i = 1:length(traindir)
	t = cell2mat(traindir(i));
    scanFile = getScanFile(t);
    ppmFile = getPpmFile(t);    
    segFolder = strcat(t,'seg2D/');
    %go to the segFolder, and for each of the ppms
    segs = catalogue(segFolder,'ppm');
    %find the obj from labels
    objLoc = getLabelMat(t,objPath);
    if (~exist(objLoc,'file')) continue; end;
    obj = load(objLoc);
    %disp(t);
    for j = 1:length(segs)
        %get the bounding box from the name and go to that image and crop
        %out
        n = cell2mat(segs(j));
        n2 = n;
        eArray = strsplit(n,'-');
        n = cell2mat(eArray(1));
        %disp(n);
        [x,y,~] = fileparts(n);
        e = fullfile(x,y);
        %get the bndbox
        bndBox = zeros(1,4);
        bndbox = strsplit(y,'_');
        for k = 1:4
            bndBox(k) = str2num(cell2mat(bndbox(k)));
        end
        label = findLabel( bndBox, obj, threshold );
        disp(label);
        %add the label to the name
        newName = strcat(e,'-',label,'.ppm');
        mvCmd = sprintf(mvPrefix, n2, newName);
        %disp(mvCmd);
        system(mvCmd);
    end
end
for i = 1:length(testdir)
	t = cell2mat(testdir(i));
    scanFile = getScanFile(t);
    ppmFile = getPpmFile(t);    
    segFolder = strcat(t,'seg2D/');
    %go to the segFolder, and for each of the ppms
    segs = catalogue(segFolder,'ppm');
    %find the obj from labels
    objLoc = getLabelMat(t,objPath);
    if (~exist(objLoc,'file')) continue; end;
    obj = load(objLoc);
    %disp(t);
    for j = 1:length(segs)
        %get the bounding box from the name and go to that image and crop
        %out
        n = cell2mat(segs(j));
        n2 = n;
        eArray = strsplit(n,'-');
        n = cell2mat(eArray(1));
        %disp(n);
        [x,y,~] = fileparts(n);
        e = fullfile(x,y);
        %get the bndbox
        bndBox = zeros(1,4);
        bndbox = strsplit(y,'_');
        for k = 1:4
            bndBox(k) = str2num(cell2mat(bndbox(k)));
        end
        label = findLabel( bndBox, obj, threshold );
        disp(label);
        %add the label to the name
        newName = strcat(e,'-',label,'.ppm');
        mvCmd = sprintf(mvPrefix, n2, newName);
        %disp(mvCmd);
        system(mvCmd);
    end
end
