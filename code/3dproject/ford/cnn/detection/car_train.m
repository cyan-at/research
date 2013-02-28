function model = car_train(cls, n, note, sbin)

% model = car_train(cls, n, note)
% Train a model with 2*n components using the ANT dataset.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG)

% At every "checkpoint" in the training process we reset the
% RNG's seed to a fixed value so that experimental results are
% reproducible.
initrand();
if ~exist('cls','var') || isempty(cls), cls = 'car'; end
if ~exist('note','var'), note = ''; end

globals_car;
[pos, neg] = car_data(cls, true);
% split data by aspect ratio into n groups
spos = split(cls, pos, n);

cachesize = 24000;
maxneg = 50;

% car_train_sub root filters using warped positives & random negatives
try
    load([cachedir cls '_lrsplit1']);
catch
    initrand();
    for i = 1:n
        % split data into two groups: left vs. right facing instances
        models{i} = car_initmodel(cls, spos{i}, note, 'N', sbin);
        inds = car_lrsplit(models{i}, spos{i}, i);
        models{i} = car_train_sub(cls, models{i}, spos{i}(inds), neg, i, 1, 1, 1, ...
            cachesize, true, 0.7, false, ['lrsplit1_' num2str(i)]);
    end
    save([cachedir cls '_lrsplit1'], 'models');
end

% car_train_sub root left vs. right facing root filters using latent detections
% and hard negatives
try
    load([cachedir cls '_lrsplit2']);
catch
    initrand(); 
    for i = 1:n
        models{i} = lrmodel(models{i});
        models{i} = car_train_sub(cls, models{i}, spos{i}, neg(1:maxneg), 0, 0, 4, 3, ...
            cachesize, true, 0.7, false, ['lrsplit2_' num2str(i)]);
    end
    save([cachedir cls '_lrsplit2'], 'models');
end

% merge models and car_train_sub using latent detections & hard negatives
try
    load([cachedir cls '_mix']);
catch
    initrand();
    model = mergemodels(models);
    model = car_train_sub(cls, model, pos, neg(1:maxneg), 0, 0, 1, 5, ...
        cachesize, true, 0.7, false, 'mix');
    save([cachedir cls '_mix'], 'model');
end

% add parts and update models using latent detections & hard negatives.
try
    load([cachedir cls '_parts']);
catch
    initrand();
    for i = 1:2:2*n
        model = model_addparts(model, model.start, i, i, 8, [6 6]);
    end
    model = car_train_sub(cls, model, pos, neg(1:maxneg), 0, 0, 8, 10, ...
        cachesize, true, 0.7, false, 'parts_1');
    model = car_train_sub(cls, model, pos, neg, 0, 0, 1, 5, ...
        cachesize, true, 0.7, true, 'parts_2');
    save([cachedir cls '_parts'], 'model');
end

save([cachedir cls '_final'], 'model');
