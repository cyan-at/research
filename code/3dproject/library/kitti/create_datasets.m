patchSource = '/mnt/neocortex/scratch/3dproject/data/KITTI/patches2/';
pcSource = '/mnt/neocortex/scratch/3dproject/data/KITTI/pc2/';
classes = {'car/','van/','pedestrian/','cyclist/','truck/'};
carSource1 = strcat(patchSource, 'car/');
vanSource1 = strcat(patchSource, 'van/');
pedSource1 = strcat(patchSource, 'pedestrian/');
cycSource1 = strcat(patchSource, 'cyclist/');
truSource1 = strcat(patchSource, 'truck/');
carSource2 = strcat(pcSource, 'car/');
vanSource2 = strcat(pcSource, 'van/');
pedSource2 = strcat(pcSource, 'pedestrian/');
cycSource2 = strcat(pcSource, 'cyclist/');
truSource2 = strcat(pcSource, 'truck/');
for i = length(classes)
   source1 = strcat( 
end


