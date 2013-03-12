function mat2pcdford(combined, saveName)
%converts the file to PCD format somewhat and saves it at saveName
%combined row is [x y z rgb r g b x y cam scan]
fid = fopen(saveName,'w');
fprintf(fid, '# .PCD v0.7 - Point Cloud Data file format\n');
fprintf(fid, 'VERSION 0.7\n');
fprintf(fid, 'FIELDS source x y z rgb r g b pixelx pixely cam scan\n');
fprintf(fid,'SIZE 4 4 4 4 4 4 4 4 4 4 4 4\n');
fprintf(fid,'TYPE F F F F U F F F F F F F\n');
fprintf(fid,'COUNT 1 1 1 1 1 1 1 1 1 1 1 1\n');
pointCountStr = sprintf('POINTS %s\n', num2str(size(combined,1)));
fprintf(fid, pointCountStr);
fprintf(fid,'VIEWPOINT 0 0 0 1 0 0 0\n');
fprintf(fid,'DATA ascii\n');
% begin points
for i = 1:size(combined,1)
    line = sprintf('%s',num2str(combined(i,:)));
    fprintf(fid,sprintf('%s\n',line));
end
fclose(fid);
end