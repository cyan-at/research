function rbf_name = train_rbf_model(pos_scores,neg_scores,xfeature,yfeature,posWeight, negWeight,opt_standardize)
%pos_scores is a struct with 2D, 3D, ... and a matrix field %[neg_cnn;neg_two;neg_three];
%expects xfeature: 3D, 2D, CNN, objectivity struct with fields 'name' and
%'matrix_idx'
%expect yfeature: 3D, 2D, CNN, objectivity struct with fields 'name' and
%'matrix_idx'

%dependencies
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%pick out matrix idx, prep data
xfeat = xfeature.matrix_idx; %cnn;
yfeat = yfeature.matrix_idx; %three;
x1 = pos_scores.matrix(xfeat,:);
y1 = pos_scores.matrix(yfeat,:);
x2 = neg_scores.matrix(xfeat,:);
y2 = neg_scores.matrix(yfeat,:);
labels1 = ones(1,size(x1,2));
labels2 = zeros(1,size(x2,2));
x = [x1,x2];
y = [y1,y2];
labels = [labels1,labels2];
%zero mean and standardize deviation
if opt_standardize
    xmean = mean(x(:));
    xstd = std(x(:));
    ymean = mean(y(:));
    ystd = std(y(:));
    x=x-xmean;
    x=x/xstd;
    y=y-ymean;
    y=y/ystd;
end
X = [x',y'];
y = labels';

%some overhead
%rbf_name is the name of the rbf model
rbf_name = sprintf('pos%d_neg%d_x%s_y%s_do',posWeight,negWeight,xfeature.name,yfeature.name);
%make directories
experiment = 'rbf_test';
heatmap = sprintf('%s/%s/%s/heatmap.png',pwd,experiment,rbf_name);
model_location = sprintf('%s/%s/%s/model.mat',pwd,experiment,rbf_name);
plotname = sprintf('%s/%s/%s/plot.png',pwd,experiment,rbf_name);
ensure(sprintf('%s/%s/%s/',pwd,experiment,rbf_name));

%do the training
close all;
% figure,
% plotData(X, y);
xlabel(xfeature.name);
ylabel(yfeature.name);
% Initialize settings for grid search
stepSize = 1;
log2cList = -1:stepSize:10;
log2gList = -10:stepSize:1;
Nlog2c = length(log2cList);
Nlog2g = length(log2gList);
heat = zeros(Nlog2c,Nlog2g); % Init heatmap matrix
bestAccuracy = 0; % Var to store best accuracy
totalRuns = Nlog2c*Nlog2g;
% Grid search to optimize cost & gamma
runCounter = 1;
for i = 1:Nlog2c
    for j = 1:Nlog2g
        log2c = log2cList(i);
        log2g = log2gList(j);
        disp([num2str(runCounter), '/', num2str(totalRuns)]);
        disp(['Trying c=', num2str(2^log2c), ' and g=', num2str(2^log2g)]);
        % Train with current cost & gamma
        params = ['-t 2 -v 10 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g), ' -w1', num2str(posWeight), ' -w-1', num2str(negWeight) ];
        accuracy = svmtrain(y, X, params);
        % Update heatmap matrix
        heat(i,j) = accuracy;
        % Update accuracy, cost & gamma if better
        if (accuracy >= bestAccuracy)
            bestAccuracy = accuracy;
            bestC = 2^log2c;
            bestG = 2^log2g;
        end
        runCounter = runCounter+1;
    end
end
hm = figure;
imagesc(heat);
colormap('jet'); 
colorbar;
set(gca,'XTick',1:Nlog2g);
set(gca,'XTickLabel',sprintf('%3.1f|',log2gList));
xlabel('Log_2\gamma');
set(gca,'YTick',1:Nlog2c);
set(gca,'YTickLabel',sprintf('%3.1f|',log2cList));
ylabel('Log_2c');
title('Grid Search over c and \gamma for RBF kernel');
saveas(hm, heatmap);
params = ['-t 2 -c ', num2str(bestC), ' -g ', num2str(bestG), ' -w1', num2str(posWeight), ' -w-1', num2str(negWeight) ];
model = svmtrain(y, X, params);
visualizeBoundary(X, y, model,xfeature.name,yfeature.name,rbf_name,plotname);
if opt_standardize
    model.xmean = xmean;
    model.ymean = ymean;
    model.xstd = xstd;
    model.ystd = ystd;
end

%save the model
save(model_location,'model');
end
