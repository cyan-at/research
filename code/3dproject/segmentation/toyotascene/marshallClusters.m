function marshallClusters( matDir, carDir, notDir, clusterIndex )
%this function goes inside of clusterDir, looking for the car_ and not_ prefix
%deals only with mat files
d = dir(matDir);
nameFolds = {d.name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
numCars = 0;
numNots = 0;
for i = 1:length(nameFolds)
    matFile = fullfile(matDir,cell2mat(nameFolds(i)));
    disp(matFile);
    [x] = strsplit(cell2mat(nameFolds(i)),'_');
    x = cell2mat(x(1));
    if (strcmp(x,'car'))
        %put it in the carDir
        numCars = numCars + 1;
        name = strcat('car_',num2str(numCars),'_',num2str(clusterIndex));
        d = carDir;
    else
        %put it in the notDir
        numNots = numNots + 1;
        name = strcat('not_',num2str(numNots),'_',num2str(clusterIndex));
        d = notDir;
    end
    n = strcat(name,'.mat');
    matFileName = fullfile(d,n);
    disp(matFileName);    
    cpCmd = sprintf('mv %s %s',matFile,matFileName);
    disp(cpCmd);
    system(cpCmd);
end
end

