function dataSet = spinImagesExt(radius,imgW,minN,rt_mat_dir,data_dir)
% Extract sift features from the image

%% data directory setup
dataSet = sprintf('radius%g_imgW%d_minN%d',radius,imgW,minN);

rt_data_dir = fullfile(data_dir,dataSet);

subfolders = dir(rt_mat_dir);
if ~exist('rt_data_dir','dir')
    mkdir(rt_data_dir);
end

for ii = 3:length(subfolders),
    subname = subfolders(ii).name;
    feapath = fullfile(rt_data_dir, subname);
    if ~exist('feapath', 'dir')
        mkdir(feapath);
    end
    if ~strcmp(subname, '.') && ~strcmp(subname, '..')
        ddir = fullfile(rt_mat_dir,subname);
        dsubfolders = dir(ddir);
        dsubfolders = dsubfolders(3:end);
        for jj=1:length(dsubfolders)
            dsubname = dsubfolders(jj).name;
            load(fullfile(ddir,dsubname));
            if strcmp(subname, 'nonlap_negs')
                obj = nonlap_neg_obj;
                clear nonlap_neg_obj;
            end
            cal_spinImages_feat(fullfile(feapath,dsubname),obj,radius,imgW,minN);
        end
    end;
end;


return