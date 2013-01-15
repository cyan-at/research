function [uv] = readPixelFile(pixelFile)
    %returns pc a data structure that is 3 x N point cloud data
    fid=fopen(pixelFile,'r');
    uv=fscanf(fid,'%f, %f',[2 inf])';  % or use num(3) instead of inf
    fclose(fid);
end