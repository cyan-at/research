%more parameters
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');

root = trainRoot;
f =    catalogue(root,'folder');
for i = 1:length(f)
    scanFolder = cell2mat(f(i));
    disp(scanFolder);
    deleteCmd1 = sprintf('rm -rf %s',strcat(root,scanFolder,'/nots/'));
    deleteCmd2 = sprintf('rm -rf %s',strcat(root,scanFolder,'/cars/'));
    system(deleteCmd1); system(deleteCmd2);
end

root = testRoot;
f =    catalogue(root,'folder');
for i = 1:length(f)
    scanFolder = cell2mat(f(i));
    disp(scanFolder);
    deleteCmd1 = sprintf('rm -rf %s',strcat(root,scanFolder,'/nots/'));
    deleteCmd2 = sprintf('rm -rf %s',strcat(root,scanFolder,'/cars/'));
    system(deleteCmd1); system(deleteCmd2);
end