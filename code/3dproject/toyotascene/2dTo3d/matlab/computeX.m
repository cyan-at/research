function x = computeX(i,opt)
try
    load xyzs.mat; load uvs.mat;
catch
    endingImage = 20;
    loadPaths;
    uvs = []; xyzs = [];
    for i = 1:endingImage
        disp(i);
        t = cell2mat(traindir(i));
        scanFile = getScanFile(t);
        scan = readscan(scanFile);
        scan = scan(1:3,:)';
        [x, y, z] = fileparts(scanFile);
        pcdFile = strcat(x,'/',y,'.pcd');
        %construct the point file to write points to
        pointFile = strcat(x,'/',y,'_points.txt');
        pixelFile = strcat(x,'/',y,'_pixels.txt');
        uv = readPixelFile(pixelFile);
        uvs = [uvs; uv];
        xyz = readPointFile(pointFile);
        xyz = [scan(xyz,:),ones(size(xyz,1),1)*i];
        xyzs = [xyzs; xyz];
    end
    save('xyzs.mat','xyzs'); save('uvs.mat','uvs');
end

if ~opt
    x = pinv(xyzs(:,1:3))*uvs;
    n = norm(xyzs(:,1:3)*x-uvs);
    msg = sprintf('Difference of norms: %e',n);
    disp(msg);
    return;
end
%find where i occurs in xyzs
first = find(xyzs(:,4)==i,1,'first');
n = 100;
while (n > 1)
    %random selection of 3 x 3
    if (~isempty(first))
        idx = randi(size(xyzs,1),2,1);
        idx = [idx; first(1)];
    else
        idx = randi(size(xyzs,1),3,1);
    end
    %estimate x projection matrix using pinv
    x = pinv(xyzs(idx,1:3))*uvs(idx,:);
    n = norm(xyzs(idx,1:3)*x-uvs(idx,:));
    %compute the difference of norms
    msg = sprintf('Difference of norms: %e',n);
    disp(msg);
    disp(xyzs(idx,4));
end

end

