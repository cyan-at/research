carpath = '/home/jumpbot/scratch/3dproject/data/KITTI/pc/car';
car2path = '/home/jumpbot/scratch/3dproject/data/KITTI/pc2/car/';

vanpath = '/home/jumpbot/scratch/3dproject/data/KITTI/pc/van';
van2path = '/home/jumpbot/scratch/3dproject/data/KITTI/pc2/van/';

cyclistpath = '/home/jumpbot/scratch/3dproject/data/KITTI/pc/cyclist';
cyclist2path = '/home/jumpbot/scratch/3dproject/data/KITTI/pc2/cyclist/';

pedestrianpath = '/home/jumpbot/scratch/3dproject/data/KITTI/pc/pedestrian';
pedestrian2path = '/home/jumpbot/scratch/3dproject/data/KITTI/pc2/pedestrian/';

truckpath = '/home/jumpbot/scratch/3dproject/data/KITTI/pc/truck';
truck2path = '/home/jumpbot/scratch/3dproject/data/KITTI/pc2/truck/';


if ~exist(car2path,'dir'), mkdir(car2path); end;
if ~exist(van2path,'dir'), mkdir(van2path); end;
if ~exist(cyclist2path,'dir'), mkdir(cyclist2path); end;
if ~exist(pedestrian2path,'dir'), mkdir(pedestrian2path); end;
if ~exist(truck2path,'dir'), mkdir(truck2path); end;

addpath(genpath('../functions'));

threshold = 0;

currentFrame = 0;
currentCounts = [];
disp('doing pedestrians...');
l = catalogue(pedestrianpath);
for i = 1:length(l)
    pc = pcd2mat(l{i});
    [f1 f2 f3] = fileparts(l{i});
    [first second] = strtok(f2, 'Pedestrian');
    frameID = regexp(first, '_', 'split'); frameID = str2num(cell2mat(frameID(1)));
    if (currentFrame == frameID)
        %if the first part matches
        z = regexp(second, '_', 'split');
        pCount = str2num(cell2mat(z(3))); %get the points
        if (sum(ismember(currentCounts,pCount)) == 0 & (pCount >= threshold))
            %if we haven't seen this count before, then create the mat, and
            %add to the currentCounts
            name = strcat(num2str(frameID), '_');
            name = strcat(name, num2str(pCount));
            name = strcat(strcat(pedestrian2path, name), '.mat');
            disp(name);
            save(name, 'pc');
            currentCounts = [currentCounts pCount];
        end
    else
        %if the first part does not match
        currentFrame = frameID;
        currentCounts = [];
        z = regexp(second, '_', 'split');
        pCount = str2num(cell2mat(z(3))); %get the points
        if (pCount >= threshold)
            name = strcat(num2str(frameID), '_');
            name = strcat(name, num2str(pCount));
            name = strcat(strcat(pedestrian2path, name), '.mat');
            disp(name); save(name, 'pc');
            currentCounts = [currentCounts pCount];
        end
    end
end