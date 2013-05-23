researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
testRoot = strcat(targetRoot,'test/');
root = testRoot;
f =    catalogue(root,'folder');
for i = 1:length(f)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    pcdDir = strcat(workingPath,'/classified/pcd/');
    mergeAllPCDs(classifiedDir)
end
