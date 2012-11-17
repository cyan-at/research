function [ pool ] = pooling(feaSet, encoder, parameters)
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
end

