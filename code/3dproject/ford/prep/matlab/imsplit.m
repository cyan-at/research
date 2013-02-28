researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
% root = trainRoot;
% fs = catalogue(root,'folder');
% for i = 1:length(fs)
%     scanFolder = strcat(root,cell2mat(fs(i))); disp(scanFolder);
%     fullimageFile = strcat(scanFolder,'/imageFull.ppm');
%     im = imread(fullimageFile);
%     %cam1
%     cam1target = strcat(scanFolder,'/cam1.png');
%     cam1box = [1 1 1616 3080/5+1];
%     cam1 = imcrop(im,cam1box);
%     cam1 = imrotate(cam1,-90);
%     cam1 = imresize(cam1,[808,618]);
%     imwrite(cam1,cam1target,'png');
%     %cam2
%     cam2target = strcat(scanFolder,'/cam2.png');
%     cam2box = [1 616 1616 3080/5+1];
%     cam2 = imcrop(im,cam2box);
%     cam2 = imrotate(cam2,-90);
%     cam2 = imresize(cam2,[808,618]);
%     imwrite(cam2,cam2target,'png');
%     %cam3
%     cam3target = strcat(scanFolder,'/cam3.png');
%     cam3box = [1 616*2 1616 3080/5+1];
%     cam3 = imcrop(im,cam3box);
%     cam3 = imrotate(cam3,-90);
%     cam3 = imresize(cam3,[808,618]);
%     imwrite(cam3,cam3target,'png');
%     %cam4
%     cam4target = strcat(scanFolder,'/cam4.png');
%     cam4box = [1 616*3 1616 3080/5+1];
%     cam4 = imcrop(im,cam4box);
%     cam4 = imrotate(cam4,-90);
%     cam4 = imresize(cam4,[808,618]);
%     imwrite(cam4,cam4target,'png');
%     %cam5
%     cam5target = strcat(scanFolder,'/cam5.png');
%     cam5box = [1 616*4 1616 3080/5+1];
%     cam5 = imcrop(im,cam5box);
%     cam5 = imrotate(cam5,-90);
%     cam5 = imresize(cam5,[808,618]);
%     imwrite(cam5,cam5target,'png');
% end

root = testRoot;
fs = catalogue(root,'folder');
for i = 1:length(fs)
    scanFolder = strcat(root,cell2mat(fs(i))); disp(scanFolder);
    fullimageFile = strcat(scanFolder,'/imageFull.ppm');
    im = imread(fullimageFile);
    %cam1
    cam1target = strcat(scanFolder,'/cam1.png');
    cam1box = [1 1 1616 3080/5+1];
    cam1 = imcrop(im,cam1box);
    cam1 = imrotate(cam1,-90);
    cam1 = imresize(cam1,[808,618]);
    imwrite(cam1,cam1target,'png');
    %cam2
    cam2target = strcat(scanFolder,'/cam2.png');
    cam2box = [1 616 1616 3080/5+1];
    cam2 = imcrop(im,cam2box);
    cam2 = imrotate(cam2,-90);
    cam2 = imresize(cam2,[808,618]);
    imwrite(cam2,cam2target,'png');
    %cam3
    cam3target = strcat(scanFolder,'/cam3.png');
    cam3box = [1 616*2 1616 3080/5+1];
    cam3 = imcrop(im,cam3box);
    cam3 = imrotate(cam3,-90);
    cam3 = imresize(cam3,[808,618]);
    imwrite(cam3,cam3target,'png');
    %cam4
    cam4target = strcat(scanFolder,'/cam4.png');
    cam4box = [1 616*3 1616 3080/5+1];
    cam4 = imcrop(im,cam4box);
    cam4 = imrotate(cam4,-90);
    cam4 = imresize(cam4,[808,618]);
    imwrite(cam4,cam4target,'png');
    %cam5
    cam5target = strcat(scanFolder,'/cam5.png');
    cam5box = [1 616*4 1616 3080/5+1];
    cam5 = imcrop(im,cam5box);
    cam5 = imrotate(cam5,-90);
    cam5 = imresize(cam5,[808,618]);
    imwrite(cam5,cam5target,'png');
end
