%iterate through the labels and for each one, get the folder
%then in that folder, do a bunch of cp commands
addpath(genpath('/home/charlie/Desktop/research/code/utilities/matlab/splitDataSet/'));
objPath = '/home/charlie/Desktop/data/mat/';
cpPrefix = 'cp %s %s';
targetDir = '/home/charlie/Desktop/research/data/toyotascene/classification2d/';
targetDirPatches = strcat(targetDir,'patches/');
targetDirTestPatches = fullfile(targetDirPatches,'test/');
targetDirTrainPatches = fullfile(targetDirPatches,'train/');
if (~exist(targetDirTrainPatches,'dir'))
    mkdir(targetDirTrainPatches);
    mkdir(targetDirTestPatches);
end;
if (~exist(strcat(targetDirTrainPatches,'not/'),'dir'))
mkdir(strcat(targetDirTrainPatches,'not/'));
mkdir(strcat(targetDirTrainPatches,'car/'));
mkdir(strcat(targetDirTestPatches,'not/'));
mkdir(strcat(targetDirTestPatches,'car/'));
end
%for each of the segment folders if it is labeled then construct the target
%and cp over to there
nots = 0;
cars = 0;
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
    for j = 1:length(segs)
        n = cell2mat(segs(j));
        eArray = strsplit(n,'-');
        c = cell2mat(eArray(2));
        [x,y,z] = fileparts(n);
        if (strcmp(c,'not.ppm'))
            disp('not');
            if (nots > 500)
                continue;
            end
            target = strcat(targetDirTrainPatches,'not/',y,'.png');
            nots = nots + 1;
        else
            disp('car');
            target = strcat(targetDirTrainPatches,'car/',y,'.png');
            cars = cars + 1;
        end
        fname = imread(n);
        imwrite(fname,target,'png');
    end
end
nots = 0;
cars = 0;
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
    for j = 1:length(segs)
        n = cell2mat(segs(j));
        eArray = strsplit(n,'-');
        c = cell2mat(eArray(2));
        [x,y,z] = fileparts(n);
        if (strcmp(c,'not.ppm'))
            disp('not');
            if (nots > 500)
                continue;
            end
            target = strcat(targetDirTestPatches,'not/',y,'.png');
            nots = nots + 1;
        else
            disp('car');
            target = strcat(targetDirTestPatches,'car/',y,'.png');
            cars = cars + 1;
        end
        fname = imread(n);
        imwrite(fname,target,'png');
    end
end
