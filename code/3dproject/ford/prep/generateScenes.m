%goes through all working directories, get the hand label xyz coordinates
%get the scene, grab all point clouds of hand labelled images, and
%construct a scene of segmentation with labels
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');

root = trainRoot;
fs =    catalogue(root,'folder');
for i = 1:length(fs)
    scanFolder = strcat(root,cell2mat(fs(i))); %disp(scanFolder);
    camMats = catalogue(scanFolder,'mat','cam');
    for j = 1:length(camMats)
        cname = cell2mat(camMats(j));
        disp(cname);
        %read the cam file, get the pc and add it to a growing scene pc
        load(cname);
    end
end
