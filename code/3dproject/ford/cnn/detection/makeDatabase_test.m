function database = makeDatabase_test()
datapath = '/mnt/neocortex/scratch/3dproject/data/ford/images/4';

%% make database
subfiles = dir(datapath);

database = [];
database.path = {};     % contain the pathes for each image of each class
database.nframe = 0;

k = 1;
for ii = 3:length(subfiles),
    subname = subfiles(ii).name;
    if isempty(strfind(subname,'.png')) & isempty(strfind(subname,'.jpg'))
        continue;
    end
    database.nframe = database.nframe + 1;
    database.path{k} = fullfile(datapath,subname);
    database.imname{k} = subname;
    k = k+1;
end;

return;