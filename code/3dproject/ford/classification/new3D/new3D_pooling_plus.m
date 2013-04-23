function [ pool ] = new3D_pooling_plus(feaSet, encoder, parameters)
%spatial pooling function, max pooling

    feaSet.feaArr = double(feaSet.feaArr);

    % Activation is what we need for SPM.
    activation = encoder.computeActivations(feaSet.feaArr); %(feaSet.feaArr, 'hard');

    % Spatial pyramid matching.
    pLevels = length(parameters.pyramid);
    pBins = parameters.pyramid .^ 2;
    tBins = sum(pBins);
    pool = zeros(size(activation, 1), tBins);

    if (size(feaSet.feaArr, 2) <= 0)
        pool = pool(:);
        return;
    end

    bId = 0;
    for cur_level = 1 : pLevels,
        nBins = pBins(cur_level);
        
        wUnit = (feaSet.width) / parameters.pyramid(cur_level);
        hUnit = (feaSet.height) / parameters.pyramid(cur_level);
        
        % Find to which spatial bin each local descriptor
        % belongs.
        xBin = ceil(feaSet.x / wUnit);
        yBin = ceil(feaSet.y / hUnit);
        idxBin = (yBin - 1) * parameters.pyramid(cur_level) + xBin;
        
        for cur_bin = 1 : nBins,
            
            bId = bId + 1;
            sidxBin = find(idxBin == cur_bin);
            if isempty(sidxBin),
                continue;
            end
            
            % Spatial max pooling
            pool(:,bId) = max(activation(:, sidxBin), [], 2);
        end
        
    end

    if bId ~= tBins,
        error('Index number error!');
    end
    
    pool = pool(:);
    pool = pool./sqrt(sum(pool.^2));
    
    %add the metadata
    meta = feaSet.meta;
    %get the cam
    cam = mode(meta(:,10));
    %maxrange
    maxrange = max(meta(:,3));
    minrange = min(meta(:,3));
    meanrange = mean(meta(:,3));
    
    pool = [pool;maxrange;minrange;meanrange;cam];
end

