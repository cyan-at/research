Code for segmenting, removing ground plane from pointclouds

Pipeline:

1. Remove statistical outliers
2. Compute difference of normals (DON) and remove points that do not have difference of normals above a threshold
3. Of the points that remain, use euclidean distance based clustering to segment pointcloud into 'objects'

Organization:

organized by Matlab / C code and driver scripts in dataset folders
