researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
testRoot = strcat(targetRoot,'test/');
root = testRoot;
f =    catalogue(root,'folder');
for i = 1:length(f)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    pcdDir = strcat(workingPath,'/classified/pcd/');
    %read all of the pcdDirs
    pcds = catalogue(pcdDir,'pcd','','all.pcd');
    allpc = [];
    for j = 1:length(pcds)
        %read the pcd into 
        name = cell2mat(pcds(j));
        disp(name);
        [~,y,~] = fileparts(name);
        parts = strsplit(y,'_');
        source = str2num(cell2mat(parts(1)));
        %read the pcd into a struct
        pc = pcd2mat(name);
        pc = [repmat(source,size(pc,1),1),pc];
        allpc = [allpc; pc];
    end
    %at this point, write allpc back to a pcd file
    saveName = strcat(pcdDir,'all.mat');
    save(saveName,'allpc');
%     %save as mat file
%     mat2pcdfordsource(allpc, saveName);
end
