function mergeAllPCDs(pcdDir)
%merges clusters, but keep the cluster info
mergePrefix = '/home/charlie/Desktop/research/code/3dproject/c/mergePCD/build/mergeAll';
pcds = strcat(pcdDir, '*.pcd');
allpcds = fullfile(pcdDir, 'all.pcd');
arguments = '';
names = dir(pcds);
for i = 1:length(names)
    z = fullfile(pcdDir,names(i).name);
    arguments = sprintf('%s %s', arguments, z);
end
arguments = sprintf('%s -o %s',arguments, allpcds);
mergeCmd = sprintf('%s %s', mergePrefix, arguments);
system(mergeCmd);
end