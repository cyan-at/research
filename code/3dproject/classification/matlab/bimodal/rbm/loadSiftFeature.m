function [cuimg] = loadSiftFeature(classes, subfolders, data_dir)

cuimg = zeros(length(classes),1);
nofolder = length(subfolders) - length(classes);
for tclass = 1:length(classes)
    subname = subfolders(classes(tclass)+nofolder).name;
    if strcmp(subname,'test'),
        subname = subfolders(classes(tclass)+nofolder+1).name;
    end
    fpath = sprintf('%s/%s',data_dir,subname);
    flist = dir(sprintf('%s/*.mat',fpath));
    if tclass == 1
        cuimg(tclass) = length(flist);
    else
        cuimg(tclass) = cuimg(tclass-1) + length(flist);
    end
end
fprintf('loading sift features done!\n');
