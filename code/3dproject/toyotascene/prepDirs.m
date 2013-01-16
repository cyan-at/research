%this script applies scanToPCD for all the point clouds
%segmentation on all code
clc;
codeDir = '/home/charlie/Desktop/research/code/';
addpath(genpath('/home/charlie/Desktop/research/code/utilities/matlab/splitDataSet/'));
sourceDir = '/home/charlie/Desktop/research/data/Toyota_scene/Velo-Cam/';
targetDir = '/home/charlie/Desktop/research/data/toyotascene/';
if (~exist(targetDir,'dir')) mkdir(targetDir); end;
% dir each directory and find the source.pcd in each directory
allPPMs = catalogue(sourceDir, 'ppm');
allScans= catalogue(sourceDir, 'txt');
traindir = {}; testdir  = {};
cutoff = length(allPPMs)/2;
for i = 1:length(allPPMs)
	ppm = cell2mat(allPPMs(i));
	scan = cell2mat(allScans(i));
	%make a new directory for this scan
	[x, y, z] = fileparts(ppm);
	[a, b, c] = fileparts(scan);
	if (i < cutoff)
		target = strcat(targetDir,'train/',y, '/');
		traindir{end+1} = target;
 	else
		target = strcat(targetDir,'test/',y,'/');
		testdir{end+1} = target;
	end
	disp(target);
	if (~exist(target,'dir')) mkdir(target); end
	ppm2 = strcat(target, y, z); %disp(ppm2);
	cpCmd1 = sprintf('cp %s %s', ppm, ppm2); %disp(cpCmd1);
	scan2 = strcat(target, b, c); %disp(scan2);
	cpCmd2 = sprintf('cp %s %s', scan, scan2); %disp(cpCmd2);
	system(cpCmd1);
	system(cpCmd2);
end