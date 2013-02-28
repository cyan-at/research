classdef extractorSI < handle
    properties
        radius = 1;
        imgW = 16;
        minN = 10;
        type= 'spinImages';
        pathStructArray = []; %an array of structs where each struct contains one srcPath and one savePath
        featurePathArray = [];
        featureSize;
    end
    methods
        function self = extractorSI(pathStructArray, radius, imgW, minN)
            if ~exist('pathStructArray','var'), error('extractorSIFT: pathStructArray missing'); end;
            if (size(pathStructArray,2) == 0), error('extractorSIFT: pathStructArray is empty'); end;
            self.pathStructArray = pathStructArray;
            for i = 1:size(self.pathStructArray,2)
                self.featurePathArray = [self.featurePathArray pathStructArray(i).savePath];
            end
            if exist('radius','var'), self.radius = radius; end;
            if exist('imgW','var'), self.imgW = imgW; end;
            if exist('minN','var'), self.minN = minN; end;
        end

        function extractAll(self)
            %we expect the srcPath to contain subdirectories for each class
            %within the directory for each class we expect just images
            disp('Extracting spinImage features...');
            for i = 1:size(self.pathStructArray,2)
                if ~exist(self.pathStructArray(i).savePath, 'dir') mkdir(self.pathStructArray(i).savePath); end
                ps = self.pathStructArray(i);
                disp(ps.srcPath); disp(ps.savePath);
                if ~self.checkForParametersFile(ps.savePath)
                    self.extract(ps.srcPath, ps.savePath, ps.class, ps.mode);
                end
            end
            disp('Done extracting');
        end
        function found = checkForParametersFile(self,path)
            srcfolder = dir(path);
            found = false;
            for i = 1:length(srcfolder)
                imgName = srcfolder(i).name;
                if (strcmp(imgName,'parameters.txt'))
                    found = true;
                end
            end
        end
        
        
        function extract(self, srcPath, savePath, class, mode)
            %we expect the mat files to contain some 'obj' objects that holds the point clouds
            % Extract features from each single image.
            srcfolder = dir(srcPath);
            for i = 1:length(srcfolder)
                matName = srcfolder(i).name;
                if ~strcmp(matName, '.') && ~strcmp(matName, '..')
                    load(fullfile(srcPath,matName));
                    if exist('nonlap_neg_obj','var')
                       obj = nonlap_neg_obj;
                    end
                    if exist('pc', 'var')
                        obj = struct;
                        obj.pointcloud = pc;
                    end
                    self.featureSize = cal_spinImages_feat(matName,savePath,obj,self.radius,self.imgW,self.minN);  
                end            
            end 
            
            % Save parameters for future reference.
            params = sprintf('%s/parameters.txt', savePath);
            fileID = fopen(params,'w');
            fprintf(fileID,'original_mat_files:%s\n', srcPath);            
            fprintf(fileID,'radius:%d\n', self.radius);
            fprintf(fileID,'minN:%f\n', self.minN);
            fprintf(fileID,'imgW:%f\n', self.imgW);
            fprintf(fileID,'method:%s\n', 'SI');
            fprintf(fileID, 'class:%d\n', class);
            fprintf(fileID, 'mode:%s\n', mode);
            fclose(fileID);
        end
    end
end 
 
