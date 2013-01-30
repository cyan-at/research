%installling boost
%install eigen
%install flann
%cmake pcl
dependenciesDir = '/mnt/neocortex/scratch/jumpbot/dependencies/';

cmakebinLocation = strcat(dependenciesDir,'cmakebuild/bin/ccmake');
cmakeFlag = strcat('-D CMAKE_INSTALL_PREFIX=',dependenciesDir,'cmakebuild/');
flag1 = strcat('-D BOOST_DATE_TIME_LIBRARY=',dependenciesDir,'boostbuild/lib/libboost_date_time.so ');
flag2 = strcat('-D BOOST_DATE_TIME_LIBRARY_DEBUG=',dependenciesDir,'boostbuild/lib/libboost_date_time.so ');
flag3 = strcat('-D BOOST_DATE_TIME_LIBRARY_RELEASE=',dependenciesDir,'boostbuild/lib/libboost_date_time.so ');

flag4 = strcat('-D BOOST_FILESYSTEM_LIBRARY=',dependenciesDir,'boostbuild/lib/libboost_filesystem.so ');
flag5 = strcat('-D BOOST_FILESYSTEM_LIBRARY_DEBUG=',dependenciesDir,'boostbuild/lib/libboost_filesystem.so ');
flag6 = strcat('-D BOOST_FILESYSTEM_LIBRARY_RELEASE=',dependenciesDir,'boostbuild/lib/libboost_filesystem.so ');

flag7 = strcat('-D BOOST_INCLUDE_DIR=',dependenciesDir,'boostbuild/include/');

flags = sprintf('%s %s %s %s %s %s %s', flag1, flag2, flag3, flag4, flag5, flag6, flag7);

currentDir = pwd;
pclDir = '/mnt/neocortex/scratch/jumpbot/dependencies/pcl/build/';
cd(pclDir);
cmakeCmd = sprintf('%s %s %s ..', cmakebinLocation, cmakeFlag, flags);
disp(cmakeCmd);
system(cmakeCmd);
cd(currentDir);