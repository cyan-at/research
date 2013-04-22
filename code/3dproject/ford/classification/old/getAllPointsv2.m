function allCords = getAllPointsv2(folder, sort_mode)
%this version without support for clusters
%Get the name of scan
scanName = sprintf('%s/scan.mat',folder);
%load the scan
load(scanName);
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);
param = PARAM;
imageName = sprintf('%s/imageFull.ppm', folder);
I = imread(imageName);
height = size(I,1)/5;
width = size(I,2);
if(height == 616)
    height = height*2;
    I = imresize(I, [height*5 width]);
end
allCords = [];
for camindex = 0:4
    K = param(camindex+1).K;
    R = param(camindex+1).R;
    t = param(camindex+1).t;
    MappingMatrix = param(camindex+1).MappingMatrix;
    pointCloud = SCAN.Cam(camindex+1).xyz;
    if(camindex < 3)
        camoffset = 2 - camindex;
    else
        camoffset = 7 - camindex;
    end
    switch (camindex)
        case 0
            o = 2;
        case 1
            o = 3;
        case 2
            o = 4;
        case 3
            o = 0;
        case 4
            o = 1;
    end
    yoffset = height*camoffset; 
    coord = grabPoints(I,pointCloud,K,MappingMatrix,yoffset,sort_mode);
    coord(:,1) = coord(:,1)-o*height;
    coord = [repmat(camindex+1,size(coord,1),1),coord];
    allCords = [allCords; coord];
    %allCords will be [camindex,u,v]
end
end