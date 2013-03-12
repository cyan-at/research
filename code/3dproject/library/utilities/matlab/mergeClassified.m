function mergeClassified(classifiedDir)
mergePrefix = '/home/charlie/Desktop/research/code/3dproject/library/utilities/c/mergePCD/build/mergeAll';
carpcds = strcat(classifiedDir, 'car_*.pcd');
notpcds = strcat(classifiedDir, 'not_*.pcd');
carspcdLoc = fullfile(classifiedDir, 'cars.pcd');
arguments = '';
carNames = dir(carpcds);
for i = 1:length(carNames)
    z = fullfile(classifiedDir,carNames(i).name);
    arguments = sprintf('%s %s', arguments, z);
end
arguments = sprintf('%s -o %s',arguments, carspcdLoc);
mergeCmd = sprintf('%s %s', mergePrefix, arguments);
system(mergeCmd);

notspcdLoc = fullfile(classifiedDir, 'nots.pcd');
arguments = '';
notNames = dir(notpcds);
for i = 1:length(notNames)
    z = fullfile(classifiedDir,notNames(i).name);
    arguments = sprintf('%s %s', arguments, z);
end
arguments = sprintf('%s -o %s',arguments, notspcdLoc);
mergeCmd = sprintf('%s %s', mergePrefix, arguments);
system(mergeCmd);
end