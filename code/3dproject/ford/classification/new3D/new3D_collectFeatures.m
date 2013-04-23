function [ featureMatrix ] = new3D_collectFeatures(featurePath, imagesPerClass, batchSize, reuse)
    %featurePath is the of mat that holds features
    %imagesPerclass is how many mat files we want to use
    %batchSize is within a given mat file
  
    %load the featureMatrix if possible
    execute = false;
    if reuse
        try
            featureMatrixPath = fullfile(featurePath, 'featureMatrix.mat');
            load(featureMatrixPath);
        catch
            disp('unable to find featureMatrix.mat');
            execute = true;
        end
    else
        execute = true;
    end
    
    if (execute)
        f = catalogue(featurePath, 'mat','',{'featureMatrix.mat'});
        %set up the featureMatrix dimensions
        fpath = f(1);
        load(cell2mat(fpath), 'feat');
        featureDimension = size(feat.feaArr,1);
        featureMatrix = zeros(featureDimension, batchSize*imagesPerClass);
        
        %generate random selection
        index = randsample(length(f), imagesPerClass, length(f) < imagesPerClass);
        
        k = 0;
        for j = 1:imagesPerClass
            p = f(index(j));
            load(cell2mat(p), 'feat');
            if (isempty(feat.feaArr))
                continue;
            end
            vectors = feat.feaArr(:,randsample(size(feat.feaArr,2),batchSize,size(feat.feaArr,2)<batchSize));
            featureMatrix(:,k+1:k+size(vectors,2)) = double(vectors);
            k = k + size(vectors,2);
        end
        
        name = 'featureMatrix.mat';
        saveName = fullfile(featurePath, name);
        save(saveName, 'featureMatrix');
    end
end