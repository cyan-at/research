function labels = getcvprLabels(points,cvprFile,img1);
clear cvpr; load(cvprFile);
%allCords row: [u,v,distancegroup,actualrange,z,horz]
labels = zeros(size(points,1),1);
for i = 1:size(points,1)
    l = seg(points(i,2),points(i,1));
    labels(i) = l;
end
end