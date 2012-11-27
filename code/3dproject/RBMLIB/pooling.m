function [ pool ] = pooling( feaSet, activation )
    %activation is, numHidden x numFeatures
    %i.e. for HOG it would be 1000 x 196 for each patch
    %numFeatures should be some square value
    
    % Spatial pyramid matching.
    pyramid = [1]; %assume a pyramid of 1 for now
    pLevels = length(pyramid);
    pBins = pyramid .^ 2;
    tBins = sum(pBins);
    pool = zeros(size(activation, 1), tBins);
    
    if (size(feaSet.feaArr, 2) <= 0)
        pool = pool(:);
        return;
    end

    bId = 0;
    for cur_level = 1 : pLevels,
        nBins = pBins(cur_level);
        
        wUnit = (feaSet.width) / pyramid(cur_level);
        hUnit = (feaSet.height) / pyramid(cur_level);
        
        % Find to which spatial bin each local descriptor
        % belongs.
        xBin = ceil(feaSet.x / wUnit);
        yBin = ceil(feaSet.y / hUnit);
        idxBin = (yBin - 1) * pyramid(cur_level) + xBin;
        
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

