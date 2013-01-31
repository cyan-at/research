function extractPatchesFromObjMat(objMatFolder, targetPatchesFolder, ignoreDifficult, carOrNeg)
%objMatFolder is the folder of obj mat files
%in this case, it would be 
%/mnt/neocortex/scratch/3dproject/data/Ford/mat/train/car
%/mnt/neocortex/scratch/3dproject/data/Ford/mat/train/nonlap_negs
%carOrNeg, 1 if car dataset, 0 if nonlap_neg data set
matContents = dir(objMatFolder);
for i = 1:length(matContents)
	subname = matContents(i).name;
	if (~strcmp(subname,'.') && ~strcmp(subname,'..')),
		l = fullfile(objMatFolder, subname);
		objNum = str2num(strtok(strtok(subname,'.mat'),'obj'));
		%disp(l);
		load(l);
		%for each bounding box
        if ~carOrNeg
            %obj = nonlap_neg_obj;
            objNum = str2num(strtok(strtok(subname,'.mat'),'neg'));
        end
        
        disp(subname);
        disp(objNum);
        
        count = 1;
		for j = 1:size(obj,2)
			if ignoreDifficult & carOrNeg
				if isfield(obj(j),'difficult') & obj(j).difficult
                    
				else
					bndbox = obj(j).bndbox;
					coord = [bndbox(1) bndbox(2) abs(bndbox(1)-bndbox(3)) abs(bndbox(2)-bndbox(4))];
					cropped = imcrop(img, coord);
					targetName = sprintf('image%.4d_%.2d.jpg',objNum,count);
					targetName = fullfile(targetPatchesFolder,targetName);
					disp(targetName);
					imwrite(cropped,targetName,'jpg');
					count = count + 1;
				end
            else
				bndbox = obj(j).bndbox;
				coord = [bndbox(1) bndbox(2) abs(bndbox(1)-bndbox(3)) abs(bndbox(2)-bndbox(4))];
				cropped = imcrop(img, coord);
				targetName = sprintf('image%.4d_%.2d.jpg',objNum,count);
				targetName = fullfile(targetPatchesFolder,targetName);
				disp(targetName);
				imwrite(cropped,targetName,'jpg');
				count = count + 1;
			end
        end
        disp(count);
        if (count == 14)
            disp('found');
            pause;
        end
	end
end

end