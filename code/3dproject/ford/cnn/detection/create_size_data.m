function fea_all = create_size_data(datadir,dataSet)
datapath = sprintf('%s/%s',datadir,dataSet);
rt_data_dir = fullfile(datapath);
subfolders = dir(rt_data_dir);

database.imnum = 0; % total image number of the database
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0;
fea_all = zeros(100000,1);
k = 0;
for i = 1:length(subfolders),
    subname = subfolders(i).name;
    if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
        database.nclass = database.nclass + 1;
        frames = dir(fullfile(rt_data_dir, subname, '*.mat'));
        c_num = length(frames);
        database.imnum = database.imnum + c_num;       
        for j = 1:c_num,
            k = k+1;
            fpath = fullfile(rt_data_dir, subname, frames(j).name);
            database.path = [database.path, fpath];
            fea_all(k) = measure_length(database,k);
        end;
    end;
end;
fea_all = fea_all(1:k);
return;

function dlength = measure_length(database,iter1)
feaSet = loaddata(database.path,iter1);
dlength = sqrt(feaSet.width.^2 + feaSet.height.^2);

return;

function data = loaddata(path,idx)

fpath = path{idx};
load(fpath);
data = feaSet;

return;