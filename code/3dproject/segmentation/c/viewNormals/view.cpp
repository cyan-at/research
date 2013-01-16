#include <pcl/io/io.h>
#include <pcl/io/pcd_io.h>
#include <pcl/features/integral_image_normal.h>
#include <pcl/visualization/cloud_viewer.h>
#include <iostream>
#include <stdio.h>
using namespace pcl;
using namespace std;
int main ()
{
// load point cloud
pcl::PointCloud<pcl::PointXYZ>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZ>);
pcl::io::loadPCDFile ("../test/test.pcd", *cloud);

// estimate normals
pcl::PointCloud<pcl::Normal>::Ptr normals (new pcl::PointCloud<pcl::Normal>);

pcl::IntegralImageNormalEstimation<pcl::PointXYZ, pcl::Normal> ne;
pcl::PointCloud<Normal>::Ptr normals_small_scale (new pcl::PointCloud<pcl::Normal>);
ne.setInputCloud(cloud);
// Create a search tree, use KDTreee for non-organized data.
pcl::search::Search<PointXYZ>::Ptr tree;
if (cloud->isOrganized ())
{
tree.reset (new pcl::search::OrganizedNeighbor<PointXYZ> ());
}
else
{
cout << "not organized" << endl;
tree.reset (new pcl::search::KdTree<PointXYZ> (false));
}
// Set the input pointcloud for the search tree
tree->setInputCloud (cloud);
ne.setInputCloud (cloud);
ne.setSearchMethod (tree);
ne.setViewPoint (std::numeric_limits<float>::max (), std::numeric_limits<float>::max (), std::numeric_limits<float>::max ());
// calculate normals with the small scale
ne.setRadiusSearch (1);
ne.compute (*normals_small_scale);
// visualize normals
pcl::visualization::PCLVisualizer viewer("PCL Viewer");
viewer.addPointCloudNormals<pcl::PointXYZ,pcl::Normal>(cloud, normals_small_scale);
viewer.setBackgroundColor(0.0,0.0,0.0);
while (!viewer.wasStopped ())
{
}
return 0;
}

