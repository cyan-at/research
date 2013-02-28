function database = makeDatabase_test_from_mat(datapath,sidx,num)
if ~exist('datapath','var')
    datapath = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment1/mat/test/car';
end

%% make database
subfiles = dir(datapath);
subfiles = subfiles(3:end);

database = [];
database.path = {};     % contain the pathes for each image of each class
database.nframe = 0;

k = 1;
for ii = sidx:sidx+num-1,
    subname = subfiles(ii).name;
%     if isempty(strfind(subname,'.png')) & isempty(strfind(subname,'.jpg'))
%         continue;
%     end
%     subfolder = dir(fullfile(datapath,subname));
%     for jj=3:length(subfolder)
%         ss = subfolder(jj).name;
        database.nframe = database.nframe + 1;
        database.path{k} = fullfile(datapath,subname);
        database.imname{k} = subname;
        k = k+1;
%     end
end;

return;