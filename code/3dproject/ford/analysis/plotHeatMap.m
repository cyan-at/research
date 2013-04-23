%load my data
numSamples = 200;
neg_target = sprintf('%s/neg_scores_%d.mat',pwd, numSamples);
pos_target = sprintf('%s/pos_scores_%d.mat',pwd, numSamples);
load(neg_target);
load(pos_target);
x1 = pos_scores.matrix(3,:);
y1 = pos_scores.matrix(2,:);
labels1 = ones(1,size(x,2));
c = repeat_char('b',size(x,2));

x2 = neg_scores.matrix(3,:);
y2 = neg_scores.matrix(2,:);
labels2 = zeros(1,size(x2,2));
c2 = repeat_char('r',size(x2,2));

x = [x1,x2];
y = [y1,y2];
labels = [labels1,labels2];
cx = [c,c2];

% On scatter plot you probably can't see the data density
close all;
scatter(x1,10*y1,'b');
hold on; axis on; grid on;
scatter(x2,10*y2,'r');
% On data density plot the structure should be visible
DataDensityPlot(x, 10*y, 20);
