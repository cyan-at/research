function model = get_model()
for i=1:8
    load(sprintf('/mnt/neocortex/scratch/3dproject/data/ford/detection_model/car_final_%d.mat',i));
    models{i} = model;
%     figure, visualizemodel(model, 1:2:length(model.rules{model.start}));
    clear model;
   % disp([cls ' model visualization']);
end

model = mergemodels(models);