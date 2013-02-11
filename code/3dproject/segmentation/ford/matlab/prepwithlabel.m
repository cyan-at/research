%this code will run through the ford data set and copy things into working
%folders for DON, 3D segmentation, 2D segmentation, CNN, etc.
%all pointclouds
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/library/functions/';
addpath '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/utilities/matlab/mat2pcd/';
dataRoot = '/mnt/neocortex/scratch/3dproject/data/ford_car_release_111020/';
imageRoot = strcat(dataRoot,'images/');
scanFolderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
if (~exist(scanFolderRoot,'dir')); mkdir(scanFolderRoot); end;
%iterate through all of the scans in the directory, and for each scan
%load the scan
for i = 1:9
   scanfile = strcat(dataRoot,'Scan',num2str(i),'.mat');
   disp(scanfile);
   load(scanfile);
   for j = 1:length(SCANS.image)
        %disp(SCANS.image(j).imageIndex);
        %create a new image directory in the withlabels directory
        index = SCANS.image(j).imageIndex;
        x = strcat(scanFolderRoot,strcat('image',num2str(index),'/'));
        pngsource = strcat(imageRoot,num2str(0),'/image',num2str(index),'.png');
        disp(pngsource);
        if (~exist(pngsource,'file')); continue; end;
        disp(sprintf('doing %s', num2str(index)));
        if (~exist(x,'dir')); mkdir(x); end;
        %move all of the cam images into the folder and the mat files
        %move the scan file over
        for cam = 1:5
            pngsource = strcat(imageRoot,num2str(cam-1),'/image',num2str(index),'.png');
            matsource = strcat(imageRoot,num2str(cam-1),'/image',num2str(index),'.mat');
            %disp(matsource); disp(pngsource);
            pngtarget = strcat(x,'cam',num2str(cam-1),'.png');
            mattarget = strcat(x,'cam',num2str(cam-1),'.mat');
            cpcmd1 = sprintf('cp %s %s', pngsource, pngtarget);
            cpcmd2 = sprintf('cp %s %s', matsource, mattarget);
            system(cpcmd1); system(cpcmd2);
            %copy over the scan file
            obj = struct;
            obj.XYZ = SCANS.XYZ;
            obj.image = SCANS.image(j);
            scantarget = strcat(x,'obj.mat');
            save(scantarget,'obj');
        end
   end
end