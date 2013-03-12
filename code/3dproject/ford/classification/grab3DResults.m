%grab all the label results
clustersMatPath = strcat(workingPath,'/clustersMat/');
allMats = catalogue(clustersMatPath,'mat');
results = [];
for i = 1:length(allMats)
    temp = cell2mat(allMats(i));
    [~,y,~] = fileparts(temp);
    info = strsplit(y,'_');
    results = [results; [   str2num(cell2mat(info(3))),...
                            str2num(cell2mat(info(4))),...
                            str2num(cell2mat(info(5))),...
                            str2num(cell2mat(info(6))),...
                            str2num(cell2mat(info(2))),...
                            ]];
end
minX = min(results(:,1),results(:,3));
maxX = max(results(:,1),results(:,3));
minY = min(results(:,2),results(:,4));
maxY = max(results(:,2),results(:,4));
results(:,1:4) = [minY, minX, maxY, maxX];