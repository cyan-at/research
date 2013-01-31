function mat2pcdrgb(pointcloud, rgbs, idx, saveName)
%converts the file to PCD format somewhat and saves it at saveName
%pointcloud is n x 3, rgb is n x 3
pointcloud = pointcloud(idx,:);
m = mean(pointcloud(:,1:3));
m2 = repmat(m,size(pointcloud,1),1);
pointcloud = pointcloud - m2;
fid = fopen(saveName,'w');
fprintf(fid, '# .PCD v0.7 - Point Cloud Data file format\n');
fprintf(fid, 'VERSION 0.7\n');
fprintf(fid, 'FIELDS x y z rgb\n');
fprintf(fid,'SIZE 4 4 4 4\n');
fprintf(fid,'TYPE F F F U\n');
fprintf(fid,'COUNT 1 1 1 1\n');
pointCountStr = sprintf('POINTS %s\n', num2str(size(rgbs,1)));
fprintf(fid, pointCountStr);
fprintf(fid,'VIEWPOINT 0 0 0 1 0 0 0\n');
fprintf(fid,'DATA ascii\n');
packPrefix = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/segmentation/toyotascene/2dTo3d/c/build/pack';
% begin points
for i = 1:size(rgbs,1)
    %disp(i);
    r = rgbs(i,1);
    g = rgbs(i,2);
    b = rgbs(i,3);
    line = sprintf('%s %s',num2str(pointcloud(i,:)),num2str(r*(2^16)+g*(2^8)+b));
    fprintf(fid,sprintf('%s\n',line));
end
fclose(fid);
end