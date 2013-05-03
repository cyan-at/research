classdef DetectionSeed
    %BBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bndbox; %should be xmin, ymin, xmax, ymax
        
        scores = []; %1 x m array of floats
        sources = []; %1 x m array of sources
        
        patch = []; %2D x 3
        data = []; %n x 3
        
        parentBoxIdx = 0;
        depth = 0;
    end
    
    methods
        function self = DetectionSeed(bndbox,data, patch)
            %bndbox is the latest formatting bndbox
            self.data = data;
            self.patch = patch;
            self.bndbox = bndbox;
        end
        
        function bbox = seekBestNeighbor(models,encoders,rbfmodel)
            
        end
    end
    
end

