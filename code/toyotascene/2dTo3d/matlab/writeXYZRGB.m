function writeXYZRGB(targetPCDFile,scan,rgbs,idx)
%targetPCDFile is the file to write to
%scan is n x 3, rgbs is n x 3
packPrefix = '/home/charlie/Desktop/research/code/toyotascene/2dTo3d/c/pack';
data = scan(idx,:);
m = mean(data(:,1:3));
m2 = repmat(m,size(data,1),1);
data = data - m2;
fid = fopen(targetPCDFile,'w');
fprintf(fid, '# .PCD v0.7 - Point Cloud Data file format\n');
fprintf(fid, 'VERSION 0.7\n');
fprintf(fid, 'FIELDS x y z rgb\n');
fprintf(fid,'SIZE 4 4 4 4\n');
fprintf(fid,'TYPE F F F F\n');
fprintf(fid,'COUNT 1 1 1 1\n');
pointCountStr = sprintf('POINTS %s\n', num2str(size(rgbs,1)));
fprintf(fid, pointCountStr);
fprintf(fid,'VIEWPOINT 0 0 0 1 0 0 0\n');
fprintf(fid,'DATA ascii\n');
% begin points
for i = 1:size(rgbs,1)
    %disp(i);
    r = rgbs(i,1);
    g = rgbs(i,2);
    b = rgbs(i,3);
    %packCmd = sprintf('%s %d %d %d',packPrefix,r,g,b);
    %[status,result] = system(packCmd);
    %suffix = sprintf('%e',str2num(result));
    suffix = bitor(bitor(bitshift(r,16),bitshift(g,8)),b);
    suffix = sprintf('%e',suffix);
    line = sprintf('%s %s',num2str(data(i,:)),suffix);
    fprintf(fid,sprintf('%s\n',line));
end
fclose(fid);
end