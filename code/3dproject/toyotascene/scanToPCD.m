function data = scanToPCD(scanPath, savePath)
%this function takes each scan file and turns it to a pcd file
    fid=fopen(scanPath,'r');
    %fname=input('Out file name? ','s');
    %fid=fopen(fname,'r');
    num=fscanf(fid,'%f',[1 1]);
    data=fscanf(fid,'%f %f %f %f',[4 num])';  % or use num(3) instead of inf
    fclose(fid);
    data = data(:,1:3);
    m = mean(data(:,1:3));
    m2 = repmat(m,size(data,1),1);
    data = data - m2;
    %need to do some processing here
    mat2pcd(data,savePath);
    disp('done');
end