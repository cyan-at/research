function model  =  car_detection(cls, n, note)
% car_detection(cls, n, note)
% Train and score a model with 2*n components.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG) features'
if ~exist('cls','var'), cls = 'car'; end
if ~exist('n','var'), n = 6; end
if ~exist('note','var'), note = datestr(datevec(now()), 'HH-MM-SS'); end
if ~exist('sbin','var'), sbin = 4; end
globals_car;
car_init;

% record a log of the training procedure
diary([cachedir cls '.log']);
% model = get_model();
model = car_train(cls, n, note, sbin);
% lower threshold to get high recall
model.thresh = min(-1.1, model.thresh);

%%% =========================================== %%%
%% detection (SHOULD BE CHANGED)
% output: extracted images with labels

%fprintf('\n ------------------------------- Kri pascal - call pascal_test --------------------------------- \n');
boxes1 = pascal_test(cls, model, 'test', 'VC', 'VC');
save mem_dump.mat
%fprintf('\n ------------------------------- Kri pascal - call pascal_eval --------------------------------- \n');
[ap1, rec, prec, thresh] = pascal_eval(cls, boxes1, 'test', 'VC', 'VC');
save mem_dump.mat
%fprintf('\n ------------------------------- Kri pascal - call bboxpred_rescore--------------------------------- \n');
[ap1, ap2] = bboxpred_rescore(cls, 'test', 'VC');

% database = makeDatabase_test();
% thresholds = linspace(-.5, -1.2, 10);
% database = makeDatabase_test_from_mat('/mnt/neocortex/scratch/norrathe/data/experiment1/mat/resize_split_all',1,10);
database = makeDatabase_test_from_mat('/mnt/neocortex/scratch/norrathe/data/Toyota_scene/resize_.2',51,30);

% recall = zeros(size(thresholds));
% precision = zeros(size(thresholds));

% parfor i=1:length(thresholds)
%     fprintf('%d thresh: %g\n',i,thresholds(i));
    savepath = sprintf('/mnt/neocortex/scratch/norrathe/data/car_detection/pre_trained_baseline/thresh%g',model.thresh);
    [ap recall precision] = car_detect_frame(model,database,savepath,1,1,model.thresh);
% end

plot(recall,precision);

title(sprintf('Precision/Recall for car: AP = %g ',ap));
xlabel('Recall');
ylabel('Precision');
savepath = '/mnt/neocortex/scratch/norrathe/data/car_detection/pre_trained_baseline/recall_prec.png';
saveas(gcf,savepath);