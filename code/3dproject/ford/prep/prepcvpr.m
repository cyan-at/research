%go through every scene, and for each scene, grab ground truths
%generate a directory of positive
%and negative pointclouds based on cvpr segmentation and ground truths

%imports
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
refinementPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/refinement/';
addpath(refinementPath);

%some parameters
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);
cartrain3dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/threed2/train/car/';
nottrain3dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/threed2/train/not/';
cartrain2dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/twod2/train/car/';
nottrain2dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/twod2/train/not/';

ensure(cartrain3dir); ensure(cartrain2dir);
ensure(nottrain3dir); ensure(nottrain2dir);

cartest3dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/threed2/test/car/';
nottest3dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/threed2/test/not/';
cartest2dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/twod2/test/car/';
nottest2dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/cvprclassification/twod2/test/not/';

ensure(cartest3dir); ensure(nottest3dir);
ensure(cartest2dir); ensure(nottest2dir);

%go through every train scene
root = trainRoot;
scenes = catalogue(root,'folder');
total = 0;
for i = 1:length(scenes)
    if (total > 600)
        break;
    end
    workingPath = strcat(root,cell2mat(scenes(i))); disp(workingPath);
    [~,sceneName,~] = fileparts(workingPath);
    %grab the ground truths
    groundTruths = grabGroundTruths(workingPath);
    %groundTruths will be n x 6 of cam bndbox difficult

    %get all points for the working path
    allCords = getAllPoints(workingPath, 'r');
	%allCords has row: [cam,u,v,distancegroup,actualrange,z,horz]

    cams = catalogue(workingPath,'mat','cam');
    %for each camera with a ground truth
    numCarsFound = 0;
    numNotsFound = 0;
    for j = 2:length(cams)
        %overhead
        c = cell2mat(cams(j)); 
        [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
        camindex = (y<4)*(4-y)+(y>=4)*(9-y);
        imgFile1 = strcat(workingPath, '/cam',num2str(y),'.png');
        cvprFile = strcat(workingPath, '/cvpr_ucm15_cam',num2str(y),'.mat');
        clear seg; load(cvprFile);
        img = imread(imgFile1);

        %get all points in this camera, and get their labels
	    points = allCords(allCords(:,1)==camindex,2:7);
        points(:,1) = ceil(points(:,1)/2);
        points(:,2) = ceil(points(:,2)/2);
        inrange = points(:,1) >0 & points(:,2) >0;
        points = points(inrange,:);
        points(:,7) = getcvprLabels(points,cvprFile);

        %get all of the ground truths
        gt = groundTruths(groundTruths(:,1)==y,2:5);
        allcarlabels = [];
        for k = 1:size(gt,1)
            numCarsFound = numCarsFound + 1;
            bndbox = gt(k,:);
            bndbox2D = [bndbox(1),bndbox(2),bndbox(3)-bndbox(1),bndbox(4)-bndbox(2)];
            patch = imcrop(img,bndbox2D);
            location2D = strcat(cartrain2dir,sceneName,'_',num2str(numCarsFound),'.png');
            %save(location2D,'patch');
            imwrite(patch,location2D,'png');
            
            [inside] = findPointsFor(bndbox, points);
            temp = points(inside,:);
            majorlabel = mode(temp(:,7));
            carlabels = unique(temp(:,7));
            temp = points(points(:,7)==majorlabel,:);
            allcarlabels = [allcarlabels; carlabels];            
            location3D = strcat(cartrain3dir,sceneName,'_',num2str(numCarsFound),'.mat');
            savecvprPoints(temp,location3D);
        end
        
        %get all the labels that aren't part of ground truths that are
        %significant
        numNotsFound = numNotsFound + 1;
        notcarlabels = points(~ismember(points(:,7),allcarlabels),:);
        first = notcarlabels(notcarlabels(:,7)==mode(notcarlabels(:,7)),:);
        left = notcarlabels(notcarlabels(:,7)~=mode(notcarlabels(:,7)),:);
        second = notcarlabels(notcarlabels(:,7)==mode(left(:,7)),:);
        
        location3D = strcat(nottrain3dir,sceneName,'_',num2str(numNotsFound),'.mat');
        savecvprPoints(first,location3D);
        firstbndbox = extractBndBoxUV(first);
        firstbndbox = [firstbndbox(1),firstbndbox(2),firstbndbox(3)-firstbndbox(1),firstbndbox(4)-firstbndbox(2)];
        patch = imcrop(img,firstbndbox);
        location2D = strcat(nottrain2dir, sceneName, '_', num2str(numNotsFound), '.png');
        %save(location2D,'patch');   
        imwrite(patch,location2D,'png');
        
        numNotsFound = numNotsFound + 1;
        
        location3D2 = strcat(nottrain3dir,sceneName,'_',num2str(numNotsFound),'.mat');
        savecvprPoints(second,location3D2);
        secondbndbox = extractBndBoxUV(second);
        secondbndbox = [secondbndbox(1),secondbndbox(2),secondbndbox(3)-secondbndbox(1),secondbndbox(4)-secondbndbox(2)];
        patch = imcrop(img,secondbndbox);
        location2D2 = strcat(nottrain2dir, sceneName, '_', num2str(numNotsFound), '.png');
        %save(location2D2,'patch');
        imwrite(patch,location2D2,'png');
        
    end
    total = total + numCarsFound;
end

disp('doing test now');
%do the same for test
%go through every test scene
root = testRoot;
scenes = catalogue(root,'folder');
total = 0;
for i = 1:length(scenes)
    if (total > 200)
        break;
    end
    workingPath = strcat(root,cell2mat(scenes(i))); disp(workingPath);
    [~,sceneName,~] = fileparts(workingPath);
    %grab the ground truths
    groundTruths = grabGroundTruths(workingPath);
    %groundTruths will be n x 6 of cam bndbox difficult

    %get all points for the working path
    allCords = getAllPoints(workingPath, 'r');
	%allCords has row: [cam,u,v,distancegroup,actualrange,z,horz]

    cams = catalogue(workingPath,'mat','cam');
    %for each camera with a ground truth
    numCarsFound = 0;
    numNotsFound = 0;
    for j = 2:length(cams)
        %overhead
        c = cell2mat(cams(j)); 
        [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
        camindex = (y<4)*(4-y)+(y>=4)*(9-y);
        imgFile1 = strcat(workingPath, '/cam',num2str(y),'.png');
        cvprFile = strcat(workingPath, '/cvpr_ucm15_cam',num2str(y),'.mat');
        clear seg; load(cvprFile);
        img = imread(imgFile1);

        %get all points in this camera, and get their labels
	    points = allCords(allCords(:,1)==camindex,2:7);
        points(:,1) = ceil(points(:,1)/2);
        points(:,2) = ceil(points(:,2)/2);
        inrange = points(:,1) >0 & points(:,2) >0;
        points = points(inrange,:);
        points(:,7) = getcvprLabels(points,cvprFile);

        %get all of the ground truths
        gt = groundTruths(groundTruths(:,1)==y,2:5);
        allcarlabels = [];
        for k = 1:size(gt,1)
            numCarsFound = numCarsFound + 1;
            bndbox = gt(k,:);
            bndbox2D = [bndbox(1),bndbox(2),bndbox(3)-bndbox(1),bndbox(4)-bndbox(2)];
            patch = imcrop(img,bndbox2D);
            location2D = strcat(cartest2dir,sceneName,'_',num2str(numCarsFound),'.png');
            %save(location2D,'patch');
            imwrite(patch,location2D,'png');
            
            [inside] = findPointsFor(bndbox, points);
            temp = points(inside,:);
            majorlabel = mode(temp(:,7));
            carlabels = unique(temp(:,7));
            temp = points(points(:,7)==majorlabel,:);
            allcarlabels = [allcarlabels; carlabels];            
            location3D = strcat(cartest3dir,sceneName,'_',num2str(numCarsFound),'.mat');
            savecvprPoints(temp,location3D);
        end
        
        %get all the labels that aren't part of ground truths that are
        %significant
        notcarlabels = points(~ismember(points(:,7),allcarlabels),:);
        first = notcarlabels(notcarlabels(:,7)==mode(notcarlabels(:,7)),:);
        left = notcarlabels(notcarlabels(:,7)~=mode(notcarlabels(:,7)),:);
        second = notcarlabels(notcarlabels(:,7)==mode(left(:,7)),:);
        
        if (~isempty(first))
            numNotsFound = numNotsFound + 1;
            location3D = strcat(nottest3dir,sceneName,'_',num2str(numNotsFound),'.mat');
            savecvprPoints(first,location3D);
            firstbndbox = extractBndBoxUV(first);
            firstbndbox = [firstbndbox(1),firstbndbox(2),firstbndbox(3)-firstbndbox(1),firstbndbox(4)-firstbndbox(2)];
            patch = imcrop(img,firstbndbox);
            location2D = strcat(nottest2dir, sceneName, '_', num2str(numNotsFound), '.png');
            %save(location2D,'patch');
            imwrite(patch,location2D,'png');
            
            numNotsFound = numNotsFound + 1;
            
            location3D2 = strcat(nottest3dir,sceneName,'_',num2str(numNotsFound),'.mat');
            savecvprPoints(second,location3D2);
            secondbndbox = extractBndBoxUV(second);
            secondbndbox = [secondbndbox(1),secondbndbox(2),secondbndbox(3)-secondbndbox(1),secondbndbox(4)-secondbndbox(2)];
            patch = imcrop(img,secondbndbox);
            location2D2 = strcat(nottest2dir, sceneName, '_', num2str(numNotsFound), '.png');
            %save(location2D2,'patch');
            imwrite(patch,location2D2,'png');
            
        end
    end
    total = total + numCarsFound;
end
