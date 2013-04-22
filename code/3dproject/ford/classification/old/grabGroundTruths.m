function groundTruths = grabGroundTruths(objPath)
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
cams = catalogue(objPath,'mat','cam');
groundTruths = [];
for i = 1:length(cams)
    c = cell2mat(cams(i));
    load(c);
    [~,y,~] = fileparts(c); y = strsplit(y,'cam'); y = str2num(cell2mat(y(2)));
        
    for j = 1:length(obj)
        if ~isempty(obj(j).truncated) && obj(j).truncated
            diff = 1;
        elseif isempty(obj(j).difficult)
            diff = 0;
        else
            diff = obj(j).difficult
        end
        groundTruths = [groundTruths;...
                [...   
                y,...
                obj(j).bndbox,...
                diff
                ]];
    end
end
%groundTruths will be n x 6 of cam bndbox difficult
end