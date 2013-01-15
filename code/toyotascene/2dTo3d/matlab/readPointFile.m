function [xyz] = readPointFile(pointFile)
    %returns pc a data structure that is 3 x N point cloud data
    fid=fopen(pointFile,'r');
    xyz=fscanf(fid,'%d',[1 inf])';  % or use num(3) instead of inf
    fclose(fid);
end