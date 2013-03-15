function generateDepthMap(points, targetLocation)
%generate an image of dimensions of the camera image 808 x 618
range = points(:,4);
%im will be the actual depth map, and pointcloud will be the xyz for the
%depthmap
im = zeros(808,616);
for i = 1:size(points,1)
    %set the depth to be the depth 'color'
    if (min(points(i,:)) <= 0)
        continue;
    end
    im(points(i,2),points(i,1)) = range(i);
end
save(targetLocation,'im');
end