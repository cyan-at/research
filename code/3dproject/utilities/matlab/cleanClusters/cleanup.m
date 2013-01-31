% cleans up the segment pcds from the segmentation dataset
% run this script after batch segmentation job
rootDir = '/home/charlie/Desktop/research/data/segmentation/';
hascarDir = strcat(rootDir, 'hascar/');
nocarDir = strcat(rootDir, 'nocar/');
% has car directory
d = dir(hascarDir);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for i = 1:length(nameFolds)
    % for each sub dir, for each file besides the pcd file, remove that
    % file
    f = fullfile(hascarDir, cell2mat(nameFolds(i)));
    removeSegments(f);
end
% no car directory
n = dir(nocarDir);
isub = [n(:).isdir];
nameFolds = {n(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
for j = 1:length(nameFolds)
    % for each sub dir, for each file besides the pcd file, remove that
    % file
    f = fullfile(nocarDir, cell2mat(nameFolds(j)));
    disp(f);
    removeSegments(f);
end

