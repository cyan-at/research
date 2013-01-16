function data = loadPointCloud(file)
    fid=fopen(file,'r');
    num=fscanf(fid,'%f',[1 1]);
    data=fscanf(fid,'%f %f %f %f',[4 num])';  % or use num(3) instead of inf
    fclose(fid);
end