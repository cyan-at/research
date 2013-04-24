%load my data
numSamples = 80;
suffix = sprintf('_%d',numSamples);
classifier = 'si_kmeans_tri_pyr3_h2048_imgW16_minN10_r2_imgperclass80_plus';
neg_target = sprintf('%s/%s/neg_scores%s.mat',pwd, classifier, suffix);
pos_target = sprintf('%s/%s/pos_scores%s.mat',pwd, classifier, suffix);
load(neg_target);
load(pos_target);

%[neg_scores_cnn;neg_scores_2D;neg_scores_3D];
cnn = 1;
two = 2;
three = 3;
xfeature = 'CNN';
yfeature = '3D';
xfeat = cnn;
yfeat = three;
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
% x=x-mean(x(:));
% x=x/std(x(:));
% y=y-mean(y(:));
% y=y/std(y(:));

% On scatter plot you probably can't see the data density
close all;
scatter(x1,10*y1,'b');
title(sprintf('%s (x-axis) vs. %s (y-axis), r = neg, b = pos',xfeature,yfeature));
xlabel(xfeature);
ylabel(yfeature);
hold on; axis on; grid on;
scatter(x2,10*y2,'r');
% On data density plot the structure should be visible
DataDensityPlot(x, 10*y, 30);
