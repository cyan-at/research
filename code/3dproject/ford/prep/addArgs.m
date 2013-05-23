% add the cam suffix to each pcd file name
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
root = testRoot;
f =    catalogue(root,'folder');
for i = 1:length(f)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    matDir = strcat(workingPath,'/clusters/');
    matDir2 = strcat(workingPath,'/clustersMat/'); ensure(matDir2);
    ensure(matDir2);
    pcds = catalogue(matDir,'pcd');
    for j = 1:length(pcds)
        c = cell2mat(pcds(j));
        k = strfind(c, '_');
        if (~isempty(k))
            temp = strsplit(c,'_');
            temp = cell2mat(temp(1));
            c2 = strcat(temp,'.pcd');
            [x,y,z] = fileparts(c2);
        else
            [x,y,z] = fileparts(c);
        end
        d = strcat(matDir2,y);
        pc = pcd2mat(c);
        cameras = unique(pc(:,10));
        if (size(cameras,1) == 1)
            cam = cameras(1);
        else
            %get the mode camera and filter out only points in that camera
            cam = mode(pc(:,10));
            idx = find(pc(:,10)==cam);
            pc = pc(idx,:);
        end
        % at this point we know that pc and cam are
        %get the bounding box for pc
        [bndbox,~,~] = extractBndbox(pc);
        bndboxStr = strcat(num2str(bndbox(1)),'_',num2str(bndbox(2)), '_', num2str(bndbox(3)), '_', num2str(bndbox(4)));
        % we construct the new name for the thing
        d = strcat(d,'_',num2str(cam),'_',bndboxStr,'.mat');
        rmCmd = sprintf('rm %s',c); system(rmCmd); %remove the original pcd file
        %save the new stuff
        mat2pcdford(pc, d);
    end
end