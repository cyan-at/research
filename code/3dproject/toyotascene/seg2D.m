%in each of these directories, apply the felzen segmentation
loadPaths;
felzenPrefix = strcat(codeDir, 'segmentation/c/felzen/segment');
felzenArgs = '2 300 150';
for i = 1:length(traindir)
	t = cell2mat(traindir(i));
    scanFile = getScanFile(t);
    ppmFile = getPpmFile(t);    
    %make the segment folder to keep all of the 
    segFolder = strcat(t,'seg2D/');
    segFile = strcat(t,'seg2D.ppm');
    if (~exist(segFolder,'dir')) mkdir(segFolder); end;
    segCmd = sprintf('%s %s %s %s %s',felzenPrefix,felzenArgs,ppmFile,segFile, segFolder);
    system(segCmd);
end
for i = 1:length(testdir)
	t = cell2mat(testdir(i));
    scanFile = getScanFile(t);
    ppmFile = getPpmFile(t);    
    %make the segment folder to keep all of the 
    segFolder = strcat(t,'seg2D/');
    segFile = strcat(t,'seg2D.ppm');
    if (~exist(segFolder,'dir')) mkdir(segFolder); end;
    segCmd = sprintf('%s %s %s %s %s',felzenPrefix,felzenArgs,ppmFile,segFile, segFolder);
    system(segCmd);
end