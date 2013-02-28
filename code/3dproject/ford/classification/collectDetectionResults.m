function [results] = collectDetectionResults( pcdDir )
detectionFile = strcat(pcdDir,'detection.txt');
fid = fopen(detectionFile,'r');
tline = fgets(fid);
results = [];
while ischar(tline)
    %disp(tline);
    %parse the tline to get the pcd id
    s = strsplit(tline,':');
    pcdID = str2num(s{1});
    t = strsplit(s{2},' '); t2 = t(1:5);
    t3 = t(8); t3 = cell2mat(t3); t3 = strsplit(t3,'|'); t3 = str2num(cell2mat(t3(1))); ford_score = t3;
    t4 = t(10); t4 = str2num(cell2mat(t4(1))); kitti_score = t4;
    bndbox = [str2num(cell2mat(t2(1))),str2num(cell2mat(t2(2))),str2num(cell2mat(t2(3))),str2num(cell2mat(t2(4)))];
    cam = str2num(cell2mat(t2(5)));
    fordlabel = cell2mat(t(6)); fordlabel = strsplit(fordlabel,'|'); fordlabel = str2num(cell2mat(fordlabel(2)));
    kittilabel = cell2mat(t(8)); kittilabel = strsplit(kittilabel,'|'); kittilabel = str2num(cell2mat(kittilabel(2)));
    results = [results; [pcdID,bndbox,cam,fordlabel,kittilabel,ford_score,kitti_score]];
    tline = fgets(fid);
end
fclose(fid);
end

