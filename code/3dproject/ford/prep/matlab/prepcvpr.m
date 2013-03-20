%go through every scene, and for each scene, grab ground truths
%generate a directory of positive
%and negative pointclouds based on cvpr segmentation and ground truths
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
%load the param file
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);
car3dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprCar/threed'; ensure(car3dir);
not3dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprNot/threed'; ensure(car3dir);
car2dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprCar/twod'; ensure(car2dir);
not2dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprNot/twod'; ensure(not2dir);

%go through every train scene
root = trainRoot;
scenes = catalogue(root,'folder');
for i = 1:length(scenes)
    workingPath = strcat(root,cell2mat(scenes(i))); disp(workingPath);

    %grab the ground truths
    groundTruths = grabGroundTruths(workingPath);
    %groundTruths will be n x 6 of cam bndbox difficult

    %get all points for the working path
    allCords = getAllPoints(workingPath, 'r');
	%allCords has row: [cam,u,v,distancegroup,actualrange,z,horz]

    cams = catalogue(workingPath,'mat','cam');
    %for each camera with a ground truth
    for i = 1:length(cams)

        %overhead
        c = cell2mat(cams(i)); [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
        camindex = (y<4)(4-y)+(y>=4)(9-y);
        imgFile1 = strcat(workingPath, '/cam',num2str(y),'.png');
        cvprFile = strcat(workingPath, '/cvpr_cam',num2str(y),'.mat');
        img1 = imread(imgFile1);

        %get all points in this camera, and get their labels
	    points = allCords(allCords(:,1)==camindex,2:3);
        points(:,1) = ceil(points(:,1)/2);
        points(:,2) = ceil(points(:,2)/2);
        points(:,3) = allCords(pidx,4);
        points(:,4) = allCords(pidx,5);
        points(:,5) = allCords(pidx,6);
        points(:,6) = allCords(pidx,7);
        inrange = points(:,1) >0 & points(:,2) >0;
        points = points(inrange,:);
        points(:,7) = getcvprLabels(points,cvprFile,img1);

        %get all of the ground truths
        gt = groundTruths(groundTruths(:,1)==camindex,:);
        for j = 1:size(gt,1)
            bndbox = gt(j,2:5);
            
        end

        

    end
end
