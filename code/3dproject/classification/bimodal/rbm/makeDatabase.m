function database = makeDatabase(dataname)

% directory setup
if strcmp(dataname, 'caltech101')
    img_dir = '/mnt/neocortex/data';
    imgSet = '101_ObjectCategories';
elseif strcmp(dataname, 'caltech256')
    img_dir = '/mnt/neocortex/scratch/kihyuks/image/256_ObjectCategories';
    imgSet = '256_ObjectCategories';
elseif strcmp(dataname, '15scene')
    img_dir = '/mnt/neocortex/data';
    imgSet = '15_scene';
elseif strcmp(dataname, 'pascal2007')
    img_dir = '/mnt/neocortex/scratch/kihyuks/VOCdevkit/VOC2007';
    imgSet = 'JPEGImages';
elseif strcmp(dataname, 'caltech10')
    img_dir = '/mnt/neocortex/scratch/kihyuks/images/';
    imgSet = '10_ObjectCategories';
elseif strcmp(dataname, 'caltech10_randscale')
    img_dir = '/mnt/neocortex/scratch/kihyuks/images/';
    imgSet = '10_ObjectCategories_randscale';
end
rt_img_dir = fullfile(img_dir, imgSet);

%% make database
subfolders = dir(rt_img_dir);

database = [];
database.imnum = 0;
database.cname = {}; % name of each class
database.label = []; % label of each class
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0;

k = 1;
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    if ~strcmp(subname, '.') && ~strcmp(subname, '..') && ~strcmp(subname, 'test'),
        database.nclass = database.nclass + 1;
        database.cname{database.nclass} = subname;
        frames = dir(fullfile(rt_img_dir, subname, '*.jpg'));
        for jj = 1:length(frames),
            database.path{k} = sprintf('%s/%s/%s',rt_img_dir,subname,frames(jj).name);
            k = k+1;
        end
        c_num = length(frames);
        database.imnum = database.imnum + c_num;
        database.label = [database.label; ones(c_num, 1)*database.nclass];
    end;
end;