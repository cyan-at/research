researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
bigRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(bigRoot,'train/');
testRoot = strcat(bigRoot,'test/');
root = testRoot;
cvprRoot = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/ford/cvpr/ford/';
imagesLocation = strcat(cvprRoot,'images/');
fs = catalogue(root,'folder');
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    cams = catalogue(workingPath,'png','cam');
    for j = 1:length(cams)
        camLocation = cell2mat(cams(j));
        [~,y,~] = fileparts(camLocation); 
        newLocation = strcat(imagesLocation,cell2mat(fs(i)),'_',y,'.png');
        cpCmd = sprintf('cp %s %s', camLocation, newLocation);
        system(cpCmd);
    end
end