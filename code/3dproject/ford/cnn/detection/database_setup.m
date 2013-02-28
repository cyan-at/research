function [database_train database_test] = database_setup(fname_save,train_datadir,test_datadir)
load(sprintf('codebook/%s.mat',fname_save));
datapath = sprintf('%s/%s',train_datadir,pars.dataSet);
rt_data_dir = fullfile(datapath);
subfolders = dir(rt_data_dir);
genus = [];
species = [];
bgenuslabel = 0;
bspecieslabel = 0;
for i = 1:length(subfolders),
    subname = subfolders(i).name;
    if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
        [spec, rem] = strtok(subname,'_');
        [gen, rem] = strtok(rem,'_');
        tmp2 = strcat(spec,'_',gen);
        
        if isempty(genus), genus{1} = strtok(subname,'_');
            species{1} = tmp2;
        else
            tmp = strtok(subname,'_');
            check = 1;
            check2 = 1;
            for j = 1:length(genus),
                if strcmp(tmp,genus{j}), check = 0; end
            end
            for j = 1:length(species)
                if strcmp(tmp2,species{j}), check2 = 0; end
            end
            if check
                if strcmp(tmp2,'background')
                    bgenuslabel = length(genus)+1;
                end
                genus{length(genus)+1} = tmp; 
            end
            if check2
                if strcmp(tmp2,'background')
                    bspecieslabel = length(species)+1;
                end
                species{length(species)+1} = tmp2; 
            end
        end
    end;
end

database_train.imnum = 0; % total image number of the database
database_train.cname = {}; % name of each class
database_train.label = []; % label of each class
database_train.path = {}; % contain the pathes for each image of each class
database_train.nclass = 0;
database_train.genuslabel = [];
database_train.sizeinfo = [];
cind = 0;
for i = 1:length(subfolders),
    subname = subfolders(i).name;
    if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
        database_train.nclass = database_train.nclass + 1;
        [spec, rem] = strtok(subname,'_');
        [gen, rem] = strtok(rem,'_');
        database_train.cname{database_train.nclass} = strcat(spec,'_',gen);
        frames = dir(fullfile(rt_data_dir, subname, '*.mat'));
        c_num = length(frames);
        database_train.imnum = database_train.imnum + c_num;
        cmp = strcmp(database_train.cname{database_train.nclass},species);
        cmp = find(cmp == 1);
        database_train.label = [database_train.label; ones(c_num, 1)*cmp];
        for gen = 1:length(genus),
            if strcmp(strtok(subname,'_'),genus{gen}), genuslabel = gen; end
        end
        database_train.genuslabel = [database_train.genuslabel; ones(c_num, 1)*genuslabel];
        database_train.cind(database_train.nclass,1) = cind+1;
        database_train.cind(database_train.nclass,2) = cind+c_num;
        cind = cind + c_num;
        [p, ~] = get_scales(subname, []);
        for j = 1:c_num,
            fpath = fullfile(rt_data_dir, subname, frames(j).name);
            database_train.path = [database_train.path, fpath];
            if isempty(p),
                database_train.sizeinfo = [database_train.sizeinfo 0];
            else
                database_train.sizeinfo = [database_train.sizeinfo 1];
            end
        end;
    end;
end;


%% testing
datapath = sprintf('%s/%s',test_datadir,pars.dataSet);
rt_data_dir = fullfile(datapath);
subfolders = dir(rt_data_dir);

database_test.imnum = 0; % total image number of the database
database_test.cname = {}; % name of each class
database_test.cind = [];
database_test.label = []; % label of each class
database_test.path = {}; % contain the pathes for each image of each class
database_test.nclass = 0;
database_test.genuslabel = [];
database_test.specieslabel = [];
database_test.sizeinfo = [];
cind = 0;
for i = 1:length(subfolders),
    subname = subfolders(i).name;
    if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
        database_test.nclass = database_test.nclass + 1;
        [spec, rem] = strtok(subname,'_');
        [gen, rem] = strtok(rem,'_');
        database_test.cname{database_test.nclass} = strcat(spec,'_',gen);
        frames = dir(fullfile(rt_data_dir, subname, '*.mat'));
        c_num = length(frames);
        database_test.imnum = database_test.imnum + c_num;
        cmp = strcmp(database_test.cname{database_test.nclass},species);
        cmp = find(cmp == 1);
        database_test.label = [database_test.label; ones(c_num, 1)*cmp];
        
        for gen = 1:length(genus),
            if strcmp(strtok(subname,'_'),genus{gen}), genuslabel = gen; end
        end
        database_test.genuslabel = [database_test.genuslabel; ones(c_num, 1)*genuslabel];
        database_test.cind(database_test.nclass,1) = cind+1;
        database_test.cind(database_test.nclass,2) = cind+c_num;
        cind = cind + c_num;
        [p, ~] = get_scales(subname, []);
        for j = 1:c_num,
            fpath = fullfile(rt_data_dir, subname, frames(j).name);
            database_test.path = [database_test.path, fpath];
            if isempty(p),
                database_test.sizeinfo = [database_test.sizeinfo 0];
            else
                database_test.sizeinfo = [database_test.sizeinfo 1];
            end
        end;
    end;
end;
database_test.specieslabel = database_test.label;
