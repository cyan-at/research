function [pos, neg] = car_data(cls, flip)

% [pos, neg] = ant_data(cls)
% Get training data from the PASCAL dataset.
if ~exist('flip','var'), flip = 0; end

globals_car;
car_init;

try
    load([cachedir cls '_train']);
catch
    % positive examples from train+val
    ids = textread(sprintf(CARopts.imgsetpath, 'Main/train'), '%s');
    pos = [];
    numpos = 0;
    for i = 1:length(ids);
        fprintf('%s: parsing positives: %d/%d\n', cls, i, length(ids));
        rec = CARreadrecord(sprintf(CARopts.annopath, ids{i}));
        clsinds = strmatch(cls, {rec.objects(:).class}, 'exact');
%         % skip difficult examples
%         diff = [rec.objects(clsinds).difficult];
%         clsinds(diff) = [];
        for j = clsinds(:)'
            numpos = numpos+1;
            pos(numpos).im = [CARopts.datadir rec.imgname];
            bbox = rec.objects(j).bbox;
            pos(numpos).x1 = bbox(1);
            pos(numpos).y1 = bbox(2);
            pos(numpos).x2 = bbox(3);
            pos(numpos).y2 = bbox(4);
            pos(numpos).flip = false;
            pos(numpos).trunc = rec.objects(j).truncated;
            if flip
                oldx1 = bbox(1);
                oldx2 = bbox(3);
                bbox(1) = rec.imgsize(1) - oldx2 + 1;
                bbox(3) = rec.imgsize(1) - oldx1 + 1;
                numpos = numpos+1;
                pos(numpos).im = [CARopts.datadir rec.imgname];
                pos(numpos).x1 = bbox(1);
                pos(numpos).y1 = bbox(2);
                pos(numpos).x2 = bbox(3);
                pos(numpos).y2 = bbox(4);
                pos(numpos).flip = true;
                pos(numpos).trunc = rec.objects(j).truncated;
            end
        end
    end
    
    % negative examples from train (this seems enough!)
    ids = textread(sprintf(CARopts.imgsetpath, 'Main/train'), '%s');
    neg = [];
    numneg = 0;
    for i = 1:length(ids);
        fprintf('%s: parsing negatives: %d/%d\n', cls, i, length(ids));
        rec = CARreadrecord(sprintf(CARopts.annopath, ids{i}));
%         clsinds = strmatch(cls, {rec.objects(:).class}, 'exact');
%         if length(clsinds) == 0
            numneg = numneg+1;
            neg(numneg).im = [CARopts.datadir rec.imgname];
            neg(numneg).flip = false;
            neg(numneg).rot = 0;
%         end
    end    
    save([cachedir cls '_train'], 'pos', 'neg');
end
end


