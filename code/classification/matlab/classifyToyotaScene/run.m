%This code will run through the toyota scene dataset do the following:
%1. reorganize every datapoint (image, pointcloud) into its own directory
%2. within that directory, convert the point cloud to pcd format
%3. clean up the pcd with removing statistical outliers
%4. show the image, prompt the user for clipping
%5. save the patches cropped out
%6. save the pointcloud bounding box coordinates
% At this point the file structure for a given datapoint is
% rootdir
%   - ppm
%   - scantxt
%   - cleaned pcd
%   - patchesdir
%   - coordinatesdir
%   - projected RGBXYZ pcd
%   - pcddir of cropped out pcds
clc;
%% this section of the code will reorganize the files
sourceRootDir = '/home/charlie/Desktop/research/data/Toyota_scene/Velo-Cam';
targetRootDir = '/home/charlie/Desktop/research/data/Toyota_scene/reorganized';
if (~exist(targetRootDir,'dir')) mkdir(targetRootDir); end;


%% this section of the code convert the point cloud to pcd format


%% this section of code will remove statistical outliers from the code


%% this section shows the image, prompts the user for clipping, clips to create patches and generates the point clouds


