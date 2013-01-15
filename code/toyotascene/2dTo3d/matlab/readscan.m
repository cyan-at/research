function [pc] = readscan(scani)
    %returns pc a data structure that is 3 x N point cloud data
    fid=fopen(scani,'r');
    %fname=input('Out file name? ','s');
    %fid=fopen(fname,'r');
    num=fscanf(fid,'%f',[1 1]);
    pc=fscanf(fid,'%f %f %f %f',[4 num])';  % or use num(3) instead of inf
    fclose(fid);
    if (~isempty(pc))
        pc = pc(:,1:4)';
    end
end