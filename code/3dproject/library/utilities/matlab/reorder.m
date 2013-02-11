%reorder the image and point clouds
addpath(genpath('/mnt/neocortex/scratch/jumpbot/code/3dproject/library/'));
source = '/mnt/neocortex/scratch/3dproject/data/KITTI/kitti_softmax_car/';
patchDir = strcat(source,'patches/');
pcDir = strcat(source,'mat/');

%iterate through the patches and mats for test directory
testCarPatchesDir = strcat(patchDir,'test/car/');
testNotPatchesDir = strcat(patchDir,'test/not/');
testCarPcDir = strcat(pcDir,'test/car/');
testNotPcDir = strcat(pcDir,'test/not/');

testCarPatches = catalogue(testCarPatchesDir);
testNotPatches = catalogue(testNotPatchesDir);

testCarPc = catalogue(testCarPcDir);
testNotPc = catalogue(testNotPcDir);

% content = [];
% currentPrefix = 0;
% currentSuffixes = [];
% %iterate through patches and pcs
% for i = 1:length(testCarPatches)
%     [x y z] = fileparts(cell2mat(testCarPatches(i)));
%     [y1 y2] = strtok(y,'_'); y1 = str2num(y1); 
%     [y2 y3] = strtok(y2,'_');
%     y2 = str2num(y2);
%     if (currentPrefix == y1)
%         currentSuffixes = [currentSuffixes y2];
%     else 
%         %reset
%         if currentPrefix ~= 0
%             %push it to the prefixes
%             x = struct();
%             x.prefix = currentPrefix;
%             x.patches = currentSuffixes;
% 
%             %iterate through the point clouds and find all point clouds
%             pcs = [];
%             for j = 1:length(testCarPc)
%                 [a b c] = fileparts(cell2mat(testCarPc(j)));
%                 [b1 b2] = strtok(b,'_'); b1 = str2num(b1);
%                 [b2 y3] = strtok(b2,'_');
%                 b2 = str2num(b2);
%                 if (b1 == currentPrefix)
%                     pcs = [pcs b2];
%                 end
%             end
%             x.pcs = pcs;
%         
%             content = [content x];
%         end
%         currentSuffixes = [y2];
%         currentPrefix = y1;
%     end
% end
% %sort the patchs and pcs
% for i = 1:length(content)
%     content(i).patches = sort(content(i).patches,'descend');
%     content(i).pcs = sort(content(i).pcs,'descend');
% end

%sort the suffixes, truncate away
% for i = 1:length(content)
%     minSize = min(length(content(i).patches),length(content(i).pcs));
%     %disp(minSize);
%     content(i).pcs = content(i).pcs(1:minSize);
%     content(i).patches = content(i).patches(1:minSize);
% end

%generate links to content
for i = 1:length(content)
    for j = 1:length(content(i).pcs)
        source = strcat(testCarPcDir, num2str(content(i).prefix));
        source = strcat(source, '_');
        source = strcat(source, num2str(content(i).pcs(j)));
        source = strcat(source, '.png');
        disp(source);
        sink = strcat(testCarPcSinkDir, num2str(content(i).prefix));
        sink = strcat(sink, '_');
        sink = strcat(sink,num2str(j));
        disp(sink);
    end
    for j = 1:length(content(i).patches)
        source = strcat(testCarPcDir, num2str(content(i).prefix));
        source = strcat(source, '_');
        source = strcat(source, num2str(content(i).pcs(j)));
        source = strcat(source, '.png');
        disp(source);
        
    end
end

