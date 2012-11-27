%this script unites 1 patch with the point cloud for it
addpath(genpath('../functions'));
patchesPath = '/mnt/neocortex/scratch/3dproject/data/KITTI/patches2/';
pcPath = '/mnt/neocortex/scratch/3dproject/data/KITTI/pc2/';
classes = {'car/','truck/','van/','pedestrian/','cyclist/'};
targetPath = '/mnt/neocortex/scratch/3dproject/data/KITTI/kitti_softmax_';
matlabpool open 4;
parfor i = 1:length(classes)
    disp(cell2mat(classes(i)));
    path1 = strcat(patchesPath, classes(i));
    path2 = strcat(pcPath, classes(i));
    dir1 = catalogue(cell2mat(path1));
    dir2 = catalogue(cell2mat(path2));
    %for each class, get the unique frame ids from patches
    targetRootDir = strcat(targetPath, classes(i));
    
    patches_prefix = strcat(targetRootDir, 'patches');
    pc_prefix = strcat(targetRootDir, 'mat');
    
    patchesTrainPrefix = strcat(patches_prefix, '/train/');
    patchesTestPrefix = strcat(patches_prefix, '/test/');
    
    patchesTrainPosPrefix = strcat(patchesTrainPrefix, classes(i));
    patchesTrainNegPrefix = strcat(patchesTrainPrefix, 'not/');
    patchesTestPosPrefix = strcat(patchesTestPrefix, classes(i));
    patchesTestNegPrefix = strcat(patchesTestPrefix, 'not/');
    
    pcTrainPrefix = strcat(pc_prefix, '/train/');
    pcTestPrefix = strcat(pc_prefix, '/test/');
    
    pcTrainPosPrefix = strcat(pcTrainPrefix, classes(i));
    pcTrainNegPrefix = strcat(pcTrainPrefix, 'not/');
    pcTestPosPrefix = strcat(pcTestPrefix, classes(i));
    pcTestNegPrefix = strcat(pcTestPrefix, 'not/');
    
    disp(targetRootDir);
%     for j = 1:length(dir1)
%         %patches
% 	disp('Doing patches');
% [f1 f2 f3] = fileparts(cell2mat(dir1(j)));
% name = strcat(f2, f3);
% n = strcat(f2, f3);
%         if (j < length(dir1)/2)
%             name = strcat(patchesTrainPosPrefix,name);
%         else
%             name = strcat(patchesTestPosPrefix,name);
%         end
%         %disp(name);
%         cmd = sprintf('cp %s %s', cell2mat(dir1(j)), cell2mat(name));
%         system(cmd);
% 	disp('copying patches');
% 	if (j < length(dir1)/4)
% 		for k = 1:length(classes)
% 			if k ~= i
% 				%for other classes
% 				negRootDir = strcat(targetPath, classes(k));
% 				negprefix = strcat(negRootDir,'patches');
% 				trainnegprefix = strcat(negprefix, '/train/not/');
% 				testnegprefix = strcat(negprefix, '/test/not/');
% 				name1 = strcat(trainnegprefix,n);
% 				name2 = strcat(testnegprefix,n);
% 				cmd1 = sprintf('cp %s %s', cell2mat(dir1(j)), cell2mat(name1));
% 				cmd2 = sprintf('cp %s %s', cell2mat(dir1(j)), cell2mat(name2));
% 				msg = sprintf('copying to not of class %s', cell2mat(classes(k)));
% 				disp(msg);
% 				system(cmd1);
% 				system(cmd2);
% 			end
% 		end
% 	end
% end
    for j = 1:length(dir2)
        [f1 f2 f3] = fileparts(cell2mat(dir2(j)));
        name = strcat(f2, f3);
        n = strcat(f2, f3);
%         disp('Doing pointclouds');
%         [f1 f2 f3] = fileparts(cell2mat(dir2(j)));
%         name = strcat(f2, f3);
%         if (j < length(dir2)/2)
%             name = strcat(pcTrainPosPrefix,name);
%         else
%             name = strcat(pcTestPosPrefix,name);
%         end
%         disp(name);
%         cmd = sprintf('cp %s %s', cell2mat(dir2(j)),cell2mat(name));
%         system(cmd);
%         disp('copying pointclouds');
if (j < length(dir2)/4)
    for k = 1:length(classes)
        if k ~= i
            %for other classes
            negRootDir = strcat(targetPath, classes(k));
            negprefix = strcat(negRootDir, 'mat');
            trainnegprefix = strcat(negprefix, '/train/not/');
            testnegprefix = strcat(negprefix, '/test/not/');
            name1 = strcat(trainnegprefix, n);
            name2 = strcat(testnegprefix, n);
            cmd1 = sprintf('cp %s %s', cell2mat(dir2(j)), cell2mat(name1));
            cmd2 = sprintf('cp %s %s', cell2mat(dir2(j)), cell2mat(name2));
            msg = sprintf('copying to not of the class %s', cell2mat(classes(k)));
            disp(msg);
            system(cmd1);
            system(cmd2);
        end
        end
    end
    end
end
    matlabpool close;
