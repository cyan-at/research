%dependencies
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%parameters
numSamples = 80;
suffix = sprintf('_%d',numSamples);
source = 'si_kmeans_tri_pyr3_h2048_imgW16_minN10_r2_imgperclass80_plus';
posWeight = 1;
negWeight = 2;
neg_target = sprintf('%s/%s/neg_scores%s.mat',pwd, source, suffix);
pos_target = sprintf('%s/%s/pos_scores%s.mat',pwd, source, suffix);
cnn = 1;
two = 2;
three = 3;
xfeature = 'CNN';
yfeature = '3D';
xfeat = cnn;
yfeat = three;
suffix = sprintf('run_%d_pos%d_neg%d_x%s_y%s',numSamples,posWeight,negWeight,xfeature,yfeature);
heatmap = sprintf('%s/%s/%s/heatmap.png',pwd,source,suffix);
model_location = sprintf('%s/%s/%s/model.mat',pwd,source,suffix);
plotname = sprintf('%s/%s/%s/plot.png',pwd,source,suffix);
ensure(sprintf('%s/%s/%s/',pwd,source,suffix));
%load my data
load(neg_target);
load(pos_target);
x1 = pos_scores.matrix(xfeat,:);
y1 = pos_scores.matrix(yfeat,:);
labels1 = ones(1,size(x1,2));
c = repeat_char('b',size(x1,2));

x2 = neg_scores.matrix(xfeat,:);
y2 = neg_scores.matrix(yfeat,:);
labels2 = zeros(1,size(x2,2));
c2 = repeat_char('r',size(x2,2));

x = [x1,x2];
y = [y1,y2];
labels = [labels1,labels2];
cx = [c,c2];

%zero mean and standardize deviation
xmean = mean(x(:));
xstd = std(x(:));
x=x-xmean;
x=x/xstd;
ymean = mean(y(:));
ystd = std(y(:));
y=y-ymean;
y=y/ystd;
X = [x',y'];
y = labels';
close all;
% figure,
% plotData(X, y);
xlabel(xfeature);
ylabel(yfeature);
% Initialize settings for grid search
stepSize = 1;
log2cList = -1:stepSize:10;
log2gList = -10:stepSize:1;
Nlog2c = length(log2cList);
Nlog2g = length(log2gList);
heat = zeros(Nlog2c,Nlog2g); % Init heatmap matrix
bestAccuracy = 0; % Var to store best accuracy
% To see how things go as grid search runs
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
        params = ['-t 2 -v 10 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
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
close all;

params = ['-t 2 -c ', num2str(bestC), ' -g ', num2str(bestG), ' -w1', num2str(posWeight), ' -w-1', num2str(negWeight) ];
model = svmtrain(y, X, params);
visualizeBoundary(X, y, model,xfeature,yfeature,suffix,plotname);
model.xstd = xstd;
model.xmean = xmean;
model.ystd = ystd;
model.ymean = ymean;
save(model_location,'model');
