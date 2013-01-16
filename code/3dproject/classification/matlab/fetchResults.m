rootDir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/10_7_12/';
classes = {'car/'};
names = {'car'};
addpath(genpath('/mnt/neocortex/scratch/jumpbot/code/3dproject/library/'));
addpath('./');
for i = 1:length(classes)
    dir_name = strcat(rootDir, cell2mat(names(i)));
    dir_name = strcat(dir_name, '/');
    results_dir = strcat(dir_name, 'results/');
    h = zeros(3,3);    
    f = figure;
    hold on; grid on; axis on;
    
    siDir = (strcat(results_dir, 'pc/'));
    load(strcat(siDir,'prec.mat')); load(strcat(siDir,'rec.mat'));
    precSI = prec; recSI = rec;
    h(:,1) = plot(precSI, recSI);
    results = loadResults(siDir);
    siAP = results.ap;
    siAP = strcat('SI AP = ', siAP);
    
    set(h(:,1), 'Color', 'r');
    
    title(cell2mat(names(i)));
    legend(h(1,:), {siAP});
    
    name = strcat('results_', cell2mat(names(i)));
    saveas(f, name, 'png');
    
end
