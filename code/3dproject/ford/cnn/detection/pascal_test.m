function boxes1 = pascal_test(cls, model, testset, year, suffix)

% boxes1 = pascal_test(cls, model, testset, year, suffix)
% Compute bounding boxes in a test set.
% boxes1 are detection windows and scores.

% Now we also save the locations of each filter for rescoring
% parts1 gives the locations for the detections in boxes1
% (these are saved in the cache file, but not returned by the function)

globals_car;
car_init;

ids = textread(sprintf(CARopts.imgsetpath, fullfile('Main',testset)), '%s');

gt(length(ids))=struct('BB',[],'diff',[],'det',[]);
BB = [];
npos = 0;
confidence = [];
box_ids = [];
% if verif
%     addpath verification;
%     try
%         load([cachedir 'svmmodel.mat']);
%     catch
%         curdir = pwd;
%         cd ../verification/
%         img_dir = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment3/patches/train/';
%         feat_dir = [cachedir cls '_feat_dir/'];
%         if ~exist([feat_dir 'pos'],'dir')
%             mkdir([feat_dir 'pos']);
%         end
%         if ~exist([feat_dir 'neg'],'dir')
%             mkdir([feat_dir 'neg']);
%         end
%         codebookPath = [cachedir 'codebook'];
%         if ~exist(codebookPath)
%             mkdir(codebookPath);
%         end
%         [Unsup svmmodel] = pre_verification(img_dir, feat_dir, 'car', 'neg', codebookPath, method);
%         savename = [cachedir 'svmmodel.mat'];
%         save(savename,'Unsup','svmmodel');
%         cd(curdir)
%     end
% end

% run detector in each image
try
  load([cachedir cls '_boxes_' testset '_' suffix]);
catch
  % parfor gets confused if we use VOCopts
  opts = CARopts;
  for i = 1:length(ids);
    fprintf('%s: testing: %s %s, %d/%d\n', cls, testset, year, ...
            i, length(ids));
%     if strcmp('inriaperson', cls)
      % INRIA uses a mixutre of PNGs and JPGs, so we need to use the annotation
      % to locate the image.  The annotation is not generally available for PASCAL
      % test data (e.g., 2009 test), so this method can fail for PASCAL.
      rec = PASreadrecord(sprintf(opts.annopath, ids{i}));
%       im = imread([opts.datadir rec.imgname]);
%     else
%         load(sprintf(opts.annopath, ids{i}));
      im = imread(sprintf(opts.imgpath, ids{i}));  
%     end
    obj = rec.objects;
    diff = zeros(length(obj),1);
    gt_bbox = zeros(length(obj),4);
    for n=1:length(obj)
        bbox = [obj(n).bndbox.xmin obj(n).bndbox.ymin obj(n).bndbox.xmax obj(n).bndbox.ymax];
        gt_bbox(n,:) = bbox;
        if isempty(obj(n).difficult) | obj(n).difficult == 0
            diff(n) = 0;
        else
            diff(n) = 1;
        end
    end
    gt(i).BB = gt_bbox';
    gt(i).diff = diff;
    gt(i).det = false(length(obj),1);
    npos = npos+sum(~gt(i).diff);
    
    [dets, boxes] = imgdetect(im, model, model.thresh);
    if ~isempty(boxes)
      boxes = reduceboxes(model, boxes);
      [dets boxes] = clipboxes(im, dets, boxes);
     % I = nms(dets, 0.2);
     I = nms(dets, 0.2);
      boxes1{i} = dets(I,[1:4 end]);
      parts1{i} = boxes(I,:);
    else
      boxes1{i} = [];
      parts1{i} = [];
    end
    box = boxes1{i};
    if isempty(box)
        continue;
    end
    BB = [BB; box(:,1:4)];
    confidence = [confidence; box(:,end)];
    box_ids = [box_ids; i*ones(size(box,1),1)];
    
    
    %showboxes(im, boxes1{i});
%       if verif
%           boxes1{i} = verification(im, boxes1{i}, svmmodel, Unsup, method, pyramid);
%       end
  end    
  [ap precision recall] = eval_dets(BB',confidence,gt,0,box_ids,npos);
%   for i=1:length(ids)
%       im = imread(sprintf(opts.imgpath, ids{i}));  
%       saveboxes(im,boxes1{i},[],sprintf([detimgpath '/%.4d.jpg'],i));
%   end
  save([cachedir cls '_boxes_' testset '_' suffix], ...
       'boxes1', 'parts1');
end
