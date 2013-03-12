function pclviewer(pointfile,point)
    if strcmp(pointfile,'')
    viewer = '/mnt/neocortex/scratch/jumpbot/dependencies/pclrepobuild/bin/pcl_viewer';
    system(sprintf('%s %s %s &', viewer, pointfile));
    pause(1)
    delete(pointfile);
end