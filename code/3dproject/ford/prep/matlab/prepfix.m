%more parameters
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
trains =    catalogue(trainRoot,'folder');
tests =      catalogue(testRoot,'folder');
root = trainRoot;
for i = 1:length(trains)
    scanFolder = cell2mat(trains(i));
    disp(scanFolder);
    %delete all the pcd files, ppm files
    deleteCmd1 = sprintf('rm -rf %s/*.pcd',strcat(root,scanFolder));
    deleteCmd2 = sprintf('rm -rf %s/*.ppm',strcat(root,scanFolder));
    system(deleteCmd1);
    system(deleteCmd2);
    scanMat = strcat(root,scanFolder,'/scan.mat');
    %load the scan file, get the images back again
    load(scanMat);
    scanDir = strcat(root,scanFolder,'/');
    z = sprintf('%04.0f',SCAN.image_index);
    cam0 = strcat(dataSource, 'IMAGES/Cam0/image',z,'.ppm');
    cam1 = strcat(dataSource, 'IMAGES/Cam1/image',z,'.ppm');
    cam2 = strcat(dataSource, 'IMAGES/Cam2/image',z,'.ppm');
    cam3 = strcat(dataSource, 'IMAGES/Cam3/image',z,'.ppm');
    cam4 = strcat(dataSource, 'IMAGES/Cam4/image',z,'.ppm');
    full = strcat(dataSource, 'IMAGES/FULL/image',z,'.ppm');
    targetImgName0 = strcat(scanDir, 'image0.ppm');
	cpCmd = sprintf('cp %s %s', cam0, targetImgName0);
    system(cpCmd);	
    targetImgName1 = strcat(scanDir, 'image1.ppm');
	cpCmd = sprintf('cp %s %s', cam1, targetImgName1);    
    system(cpCmd);
    targetImgName2 = strcat(scanDir, 'image2.ppm');
	cpCmd = sprintf('cp %s %s', cam2, targetImgName2);
    system(cpCmd);	
    targetImgName3 = strcat(scanDir, 'image3.ppm');
	cpCmd = sprintf('cp %s %s', cam3, targetImgName3);
    system(cpCmd);
    targetImgName4 = strcat(scanDir, 'image4.ppm');
	cpCmd = sprintf('cp %s %s', cam4, targetImgName4);
    system(cpCmd);
    targetImgNameFull = strcat(scanDir, 'imageFull.ppm');
    cpCmd = sprintf('cp %s %s', full, targetImgNameFull);
    system(cpCmd);
end

root = testRoot;
for i = 1:length(tests)
    scanFolder = cell2mat(tests(i));
    disp(scanFolder);
    %delete all the pcd files, ppm files
    deleteCmd1 = sprintf('rm -rf %s/*.pcd',strcat(root,scanFolder));
    deleteCmd2 = sprintf('rm -rf %s/*.ppm',strcat(root,scanFolder));
    system(deleteCmd1);
    system(deleteCmd2);
    scanMat = strcat(root,scanFolder,'/scan.mat');
    %load the scan file, get the images back again
    load(scanMat);
    scanDir = strcat(root,scanFolder,'/');
    z = sprintf('%04.0f',SCAN.image_index);
    cam0 = strcat(dataSource, 'IMAGES/Cam0/image',z,'.ppm');
    cam1 = strcat(dataSource, 'IMAGES/Cam1/image',z,'.ppm');
    cam2 = strcat(dataSource, 'IMAGES/Cam2/image',z,'.ppm');
    cam3 = strcat(dataSource, 'IMAGES/Cam3/image',z,'.ppm');
    cam4 = strcat(dataSource, 'IMAGES/Cam4/image',z,'.ppm');
    full = strcat(dataSource, 'IMAGES/FULL/image',z,'.ppm');
    targetImgName0 = strcat(scanDir, 'image0.ppm');
	cpCmd = sprintf('cp %s %s', cam0, targetImgName0);
    system(cpCmd);	
    targetImgName1 = strcat(scanDir, 'image1.ppm');
	cpCmd = sprintf('cp %s %s', cam1, targetImgName1);    
    system(cpCmd);
    targetImgName2 = strcat(scanDir, 'image2.ppm');
	cpCmd = sprintf('cp %s %s', cam2, targetImgName2);
    system(cpCmd);	
    targetImgName3 = strcat(scanDir, 'image3.ppm');
	cpCmd = sprintf('cp %s %s', cam3, targetImgName3);
    system(cpCmd);
    targetImgName4 = strcat(scanDir, 'image4.ppm');
	cpCmd = sprintf('cp %s %s', cam4, targetImgName4);
    system(cpCmd);
    targetImgNameFull = strcat(scanDir, 'imageFull.ppm');
    cpCmd = sprintf('cp %s %s', full, targetImgNameFull);
    system(cpCmd);
end