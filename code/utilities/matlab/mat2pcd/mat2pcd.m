function mat2pcd(pointcloud, saveName)
%assumes that pointcloud is a N x 3 matrix of values
%converts the file to PCD format somewhat and saves it at saveName
fid = fopen(saveName,'w');
fprintf(fid, '# .PCD v0.7 - Point Cloud Data file format\nVERSION 0.7\nFIELDS x y z\n');
fprintf(fid,'SIZE 4 4 4\n');
fprintf(fid,'TYPE F F F\n');
fprintf(fid,'COUNT 1 1 1\n');
pointCountStr = sprintf('POINTS %s\n', num2str(size(pointcloud,1)));
fprintf(fid, pointCountStr);
fprintf(fid,'VIEWPOINT 0 0 0 1 0 0 0\n');
fprintf(fid,'DATA ascii\n');
% begin points
for i = 1:size(pointcloud,1)
    fprintf(fid,sprintf('%s\n',num2str(pointcloud(i,:))));
end
fclose(fid);
end