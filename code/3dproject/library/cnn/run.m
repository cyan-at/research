root_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/pos';
annot_dir = '/mnt/neocortex/data/Pedestrian/INRIAPerson/Train/annotations';

%prepare the dataset
dataBase = dir(root_dir);
bndbox = zeros(length(dataBase)-2,4);
IMAGES = cell(1,length(dataBase)-2);
filter_size = 16;
Y = cell(1,length(dataBase)-2);
try
    load('Y.mat');
    load('images.mat');
catch
    for i=3:length(dataBase)
        idx = i-2; disp(idx);
        [tt,name] = fileparts(dataBase(i).name);
        IMAGES{idx} = im2double(imread(sprintf('%s/%s.png',root_dir,name)));
        t = textread(sprintf('%s/%s.txt',annot_dir,name),'%s');
        bndbox = [sscanf(t{end-4},'(%d,') sscanf(t{end-3},'%d)') sscanf(t{end-1},'(%d,') sscanf(t{end},'%d)')];
        Y{idx} = gety(IMAGES{idx},bndbox,filter_size);
    end
    save('Y.mat','Y');
    save('images.mat','IMAGES','-v7.3');
end
N = length(IMAGES);



