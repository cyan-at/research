function pclviewer(pointfile)
    if strcmp(pointfile,'')
        %then look at point and make a temporary file
    end
    if ~exist(pointfile,'file')
        disp('file not found');
        return;
    end
    viewer = '/mnt/neocortex/scratch/jumpbot/dependencies/pclrepobuild/bin/pcl_viewer';
    system(sprintf('%s %s %s &', viewer, pointfile));
    pause(1);
    clc;
end