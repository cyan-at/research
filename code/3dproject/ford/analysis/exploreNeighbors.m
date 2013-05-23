function [generatedBox,goodIdx] = exploreNeighbors(seedBox,img,data)
%EXPLORENEIGHBORS
%given a seedBox bounding box, we which to add it to some queue and perform
%a hill climbing search over the image and 3D environment

%dependencies
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
generatedBox = [];
goodIdx = [];

%explore the 3D neighborhood
inside = findPointsIn(seedBox,data(:,1:2));
inside = data(inside,:);
% pc = inside(:,6:8);

%generate tighten the bounding box

pcBox = pcBndbox(inside);
showbox(img,pcBox,[],'');

end