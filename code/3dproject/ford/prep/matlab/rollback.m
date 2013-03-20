%more parameters
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');

% root = trainRoot;
% f =    catalogue(root,'folder');
% for i = 1:length(f)
%     scanFolder = cell2mat(f(i));
%     disp(scanFolder);
%     deleteCmd1 = sprintf('rm -rf %s',strcat(root,scanFolder,'/*.ppm'));
%     system(deleteCmd1);
% end

root = testRoot;
f =    catalogue(root,'folder');
for i = 1:length(f)
    scanFolder = cell2mat(f(i));
    disp(scanFolder);
    deleteCmd1 = sprintf('rm -rf %s',strcat(root,scanFolder,'/cvpr_*.mat'));
    system(deleteCmd1);
end