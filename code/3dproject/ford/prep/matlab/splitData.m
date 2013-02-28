%script separates with label dataset directory into train and test
%parse through the dataset file
datasetFile = '/mnt/neocortex/scratch/3dproject/data/ford_car_release_111020/dataset.txt';
folderRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
fid = fopen(datasetFile);
tline = fgetl(fid);
train = [];

while ischar(tline)
    A = textscan(tline,'%s','delimiter','/');
    A = A{1};
    x = str2num(cell2mat(A(2)));
    if (x~=0)
        break;
    else
        disp(tline);
        B = textscan(tline,'%s','delimiter',' ');
        B = B{1};
        f = cell2mat(B(1));
        [f1 f2 f3] = fileparts(f);
        sourceFolder = strcat(folderRoot,f2,'/');
        c = str2num(cell2mat(B(2)));
        if (c == 0 || c == 1)
            %train
            targetFolder = strcat(folderRoot,'train/',f2,'/');
            cpCmd = sprintf('cp -R %s %s', sourceFolder, targetFolder);
            if (~exist(targetFolder)); system(cpCmd); end;
        else
            %test
            targetFolder = strcat(folderRoot,'test/',f2,'/');
            cpCmd = sprintf('cp -R %s %s', sourceFolder, targetFolder);
            if (~exist(targetFolder)); system(cpCmd); end;
        end
    end
    tline = fgetl(fid);
end
fclose(fid);