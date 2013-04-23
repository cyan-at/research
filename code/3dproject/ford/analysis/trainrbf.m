%dependencies
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));

%load my data
numSamples = 1000;
suffix = sprintf('_%d',numSamples);
neg_target = sprintf('%s/neg_scores%s.mat',pwd, suffix);
pos_target = sprintf('%s/pos_scores%s.mat',pwd, suffix);
load(neg_target);
load(pos_target);
x1 = pos_scores.matrix(3,:);
y1 = pos_scores.matrix(2,:);
labels1 = ones(1,size(x1,2));
c = repeat_char('b',size(x1,2));

x2 = neg_scores.matrix(3,:);
y2 = neg_scores.matrix(2,:);
labels2 = zeros(1,size(x2,2));
c2 = repeat_char('r',size(x2,2));

x = [x1,x2];
y = [y1,y2];
labels = [labels1,labels2];
cx = [c,c2];

%zero mean and standardize deviation
x=x-mean(x(:));
x=x/std(x(:));
y=y-mean(y(:));
y=y/std(y(:));

d = [x',y'];
model = svmtrain(labels', d, '-t 2');

% now plot support vectors
hold on;
sv = full(model.SVs);
plot(sv(:,1),sv(:,2),'ko');
% now plot decision area
[xi,yi] = meshgrid([min(d(:,1)):0.1:max(d(:,1))],[min(d(:,2)):0.1:max(d(:,2))]);
dd = [xi(:),yi(:)];
tic;[predicted_label, accuracy, decision_values] = svmpredict(zeros(size(dd,1),1), dd, model);toc
pos = find(predicted_label==1);
hold on;
redcolor = [1 0.8 0.8];
bluecolor = [1 1 1];
h1 = plot(dd(pos,1),dd(pos,2),'s','color',redcolor,'MarkerSize',10,'MarkerEdgeColor',redcolor,'MarkerFaceColor',redcolor);
pos = find(predicted_label==-1);
hold on;
h2 = plot(dd(pos,1),dd(pos,2),'s','color',bluecolor,'MarkerSize',10,'MarkerEdgeColor',bluecolor,'MarkerFaceColor',bluecolor);
uistack(h1, 'bottom');
uistack(h2, 'bottom');
