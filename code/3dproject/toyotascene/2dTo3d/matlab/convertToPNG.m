%in each of these directories, apply the felzen segmentation
loadPaths;
for i = 1:length(traindir)
	t = cell2mat(traindir(i));
    ppmFile = getPpmFile(t);
    pngTarget = getPngTarget(t);
    disp(pngTarget);
    im = imread(ppmFile);
    imwrite(im,pngTarget,'png');
end
for i = 1:length(testdir)
	t = cell2mat(testdir(i));
    ppmFile = getPpmFile(t);
    pngTarget = getPngTarget(t);
    disp(pngTarget);
    im = imread(ppmFile);
    imwrite(im,pngTarget,'png');
end