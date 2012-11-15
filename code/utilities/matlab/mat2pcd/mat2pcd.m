function mat2pcd(pointcloud, saveName)
%assumes that pointcloud is a N x 3 matrix of values
%converts the file to PCD format somewhat and saves it at saveName
fileID = fopen(saveName,'w');
fprintf(fid, 'Hello!\n');
fclose(fileID);
end