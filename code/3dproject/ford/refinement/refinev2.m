%go through every scene, and for each scene grab the label bnding boxes
%grab the detection results from every scene and for every cam in hand
%labels, get the corresponding detection bndboxes
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
targetRoot = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/';
trainRoot = strcat(targetRoot,'train/');
testRoot = strcat(targetRoot,'test/');
%load the param file
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);
res_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train/results_afternms_redo_train_ver2/';
output_dir = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/refine3_20_13_dev/';
ensure(output_dir);

%get the map file
fid = fopen(strcat(res_dir,'map.txt'),'r');
map = textscan(fid,'%d %s', 'Delimiter', ' ');
idx = map{1}; scene = map{2};
fclose(fid);

root = testRoot;
fs = catalogue(root,'folder');
total = 0;
totalpunished = 0;
nesting = true; punish = true; coverage = true;
for i = 1:length(fs)
    workingPath = strcat(root,cell2mat(fs(i))); disp(workingPath);
    %for every scene, get the cnn detections for this scene
    cnnDetections = grabCNN(idx, scene, res_dir, cell2mat(fs(i)));
    %cnnDetections is a n x 6 matrix of [bndbox, cam, confidence score]
    if (~isempty(cnnDetections))
        [newDetections, punished] = overlapCNNv2(workingPath,cnnDetections,PARAM,...
            nesting,punish,coverage...
            );
        totalpunished = totalpunished + punished;
        total = total + size(newDetections,1);
        %write the new detections into data_batch files
        c = strmatch(cell2mat(fs(i)),scene);
        y = idx(c);
        if ~isempty(y)
            for j = 1:length(y)
                cam = strsplit(cell2mat(scene(y(j))),'cam'); cam = cell2mat(cam(2)); cam = str2num(cam);
                det = find(newDetections(:,5)==cam);
                dataFile = strcat(output_dir,'data_batch_',num2str(y(j)),'_res.txt');
                fid = fopen(dataFile,'w');
                for z = 1:length(det)
                    jpgString = sprintf('%d_%d_%d_%d.jpg %f\n',[round(newDetections(det(z),1:4)),newDetections(det(z),6)]);
                    fprintf(fid,jpgString);
                end
                fclose(fid);
            end
        end
    end
end
fprintf('total detections found: %d\n',total);
fprintf('total detections punished: %d\n', totalpunished);
%copy over map file
mfile = strcat(res_dir,'map.txt');
cpCmd = sprintf('cp %s %s', mfile, strcat(output_dir,'map.txt'));
system(cpCmd);