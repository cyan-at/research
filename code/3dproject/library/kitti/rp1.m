path1 = '/home/jumpbot/scratch/3dproject/data/KITTI/patches/car';
path2 = '/home/jumpbot/scratch/3dproject/data/KITTI/patches2/car/';

if ~exist(path2,'dir'), mkdir(path2); end;

l = catalogue(path1);
for i = 1:length(l)
    [x y z] = fileparts(cell2mat(l(i)));
    z = regexp(y,'_','split');
    im = imread(cell2mat(l(i)));
    numpixels = size(im,1)*size(im,2);
    new_name = strcat(path2,cell2mat(z(1)));
    new_name = strcat(new_name, '_');
    new_name = strcat(new_name, num2str(numpixels));
    new_name = strcat(new_name,'.png');
    disp(new_name);
    imwrite(im,new_name);
end