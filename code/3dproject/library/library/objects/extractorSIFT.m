classdef extractorSIFT < handle
    properties
        %% parameters
        optcolor = 'gray';
        gridSpacing = 2;
        patchSize = 8;
        maxImSize = 300;
        nrml_threshold = 1;
        suppression = 0.2;
        rescaleSize = 250;    % The size to which all patches will be rescaled 
        type = 'SIFT';
        pathStructArray = []; %an array of structs where each struct contains one srcPath and one savePath
        featurePathArray = [];
        featureSize;
    end
    methods
        function self = extractorSIFT(pathStructArray, gridSpacing, patchSize)
            if ~exist('pathStructArray','var'), error('extractorSIFT: pathStructArray missing'); end;
            if (size(pathStructArray,2) == 0), error('extractorSIFT: pathStructArray is empty'); end;
            self.pathStructArray = pathStructArray;
            for i = 1:size(self.pathStructArray,2)
                self.featurePathArray = [self.featurePathArray pathStructArray(i).savePath];
            end
            if exist('gridSpacing','var'), self.gridSpacing = gridSpacing; end;
            if exist('patchSize','var'), self.patchSize = patchSize; end;
        end
        
        function extractAll(self)
            %we expect the srcPath to contain subdirectories for each class
            %within the directory for each class we expect just images
            disp('Extracting sift features...');
            for i = 1:size(self.pathStructArray,2)
                if ~exist(self.pathStructArray(i).savePath, 'dir') mkdir(self.pathStructArray(i).savePath); end
                ps = self.pathStructArray(i);
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
            
            % Extract features from each single image.
            srcfolder = dir(srcPath);
            for i = 1:length(srcfolder)
                % If image is not in .jpg or .mat format, skip it.
                % Note: if the image is a variable in .mat file, it must be
                % named 'img'.
                imgName = srcfolder(i).name;
                if isempty(strfind(imgName, '.jpg')) && isempty(strfind(imgName, '.png')) && isempty(strfind(imgName, '.mat'))
                    continue; 
                end
                
                % Create the corresponding .mat file name. If the patch
                % already has a .mat feature file, skip it.
                [~, imgIdxName, ~] = fileparts(imgName);
                saveName = sprintf('%s.mat', imgIdxName);
                if exist(fullfile(savePath, saveName), 'file')
                    continue;
                end

                % Extraction.
                if ~isempty(strfind(imgName, '.jpg')) || ~isempty(strfind(imgName, '.png'))
                    I = imread(fullfile(srcPath, imgName));  
                end
                if ~isempty(strfind(imgName, '.mat'))
                    load(fullfile(srcPath, imgName));
                    I = img;
                end
                
                fprintf('Processing sift %s ...\n', imgName);
                I = imresize(I, [self.rescaleSize self.rescaleSize]);
                feat = calcSIFT(I, self.patchSize, self.gridSpacing, self.suppression);
                self.featureSize = size(feat);
                % Save features to .mat in featPath.
                save(fullfile(savePath, saveName), 'feat');
            end 
            % Save parameters for future reference.
            params = sprintf('%s/parameters.txt', savePath);
            fileID = fopen(params,'w');
            fprintf(fileID,'original_images:%s\n', srcPath);            
            fprintf(fileID,'optcolor:%s\n', self.optcolor);
            fprintf(fileID,'patchSize:%d\n', self.patchSize);
            fprintf(fileID,'gridSpacing:%d\n', self.gridSpacing);
            fprintf(fileID,'maxImSize:%d\n', self.maxImSize);
            fprintf(fileID,'nrml_threshold:%f\n', self.nrml_threshold);
            fprintf(fileID,'suppression:%f\n', self.suppression);
            fprintf(fileID,'method:%s\n', 'sift');
            fprintf(fileID, 'class:%d\n', class);
            fprintf(fileID, 'mode:%s\n', mode);
            fclose(fileID);
        end
    end
end 
