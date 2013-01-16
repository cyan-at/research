function [ feat, label ] = featsAndLabels(encoder, featurePath, pars)
% Calculate the activations and add labels. featurePath should
% be the root path that contains feature files.
            
%Returning value:
% feat is a matrix of [ num_hid * (sum(pyramid .^ 2)) x #images ]
% label is a colum vector of 1s and 0s, which
% indicate if the image of its index is a car or not.

parameters = loadParameters(featurePath);
frames = catalogue(featurePath, parameters);
numImages = length(frames);

feat = zeros(encoder.numHidden * (sum(pars.pyramid .^ 2)), numImages);
label = ones(1, numImages)*parameters.class;
i = 1;

while i <= numImages
    tS = tic;
    % Print dots to indicate progress.
    if ~mod(i, 100)
        tE = toc(tS);
        fprintf('.%d, %.4g\n',i,tE);
        tS = tic;
    else
        fprintf('.');
    end
    feat_batch = cell(12, 1);
    j = 1;
    while (j <= 12) && (i <= numImages)
        feat_batch{j} = load(cell2mat(frames(i)));
        j = j + 1;
        i = i + 1;
    end
    
    batch_size = sum(~cellfun(@isempty, feat_batch));
    feat_sub = zeros(size(feat, 1), batch_size);
    for k = 1 : batch_size
        feat_sub(:, k) = pooling(feat_batch{k}.feat, encoder, pars);
    end
    feat(:, i - j + 1 : i - 1) = feat_sub;
end

             
end  