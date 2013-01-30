cmakebinLocation = '/mnt/neocortex/scratch/jumpbot/dependencies/cmakebuild/bin/cmake';
flag = '-D CMAKE_INSTALL_PREFIX=/mnt/neocortex/scratch/jumpbot/dependencies/eigenbuild/';
currentDir = pwd;
eigenDir = '/mnt/neocortex/scratch/jumpbot/dependencies/eigen/build_dir/';
cd(eigenDir);
cmd = sprintf('%s %s ..', cmakebinLocation, flag);
disp(cmd);
system(cmd);
cd(currentDir);