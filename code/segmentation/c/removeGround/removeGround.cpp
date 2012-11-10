#include <iostream>
#include <pcl/ModelCoefficients.h>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/sample_consensus/method_types.h>
#include <pcl/sample_consensus/model_types.h>
#include <pcl/segmentation/sac_segmentation.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/filters/extract_indices.h>
#include <vector>

using namespace std;
using namespace pcl;

int main (int argc, char** argv)
{
  pcl::PointCloud<pcl::PointXYZ>::Ptr cloud;
  // Fill in the cloud data
  pcl::PCDReader reader;
  reader.read ("../test/test.pcd", *cloud);
  
  vector<float> xyzVector;
  // Compute the most commonly occuring z value
  cout << cloud->size() << endl;
  /*
  for (int i = 0; i < cloud->size(); ++i){
  	PointXYZ temp = cloud->at(i);
	cout << temp.z << endl;
  }
  */
  // Write the ground removed to a pcd file
  pcl::PCDWriter writer;
  // writer.write<pcl::PointXYZ> ("test/groundRemoved.pcd", *cloud_filtered, false);
  return (0);
}
