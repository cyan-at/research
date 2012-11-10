#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <getopt.h>

#include <pcl/point_types.h>
#include <pcl/ModelCoefficients.h>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/sample_consensus/method_types.h>
#include <pcl/sample_consensus/model_types.h>
#include <pcl/segmentation/sac_segmentation.h>

using namespace std;
using namespace boost;
using namespace pcl;

int main (int argc, char** argv)
{
	///The file to read from.
	string infile;
	vector<string> strs;
	
	// specify the options
	static struct option long_options[] = {
		{"infile", required_argument, 0, 'i'}
	};
	while (1){
		// getopt_long stores the option index here
		int option_index = 0;
		int c = getopt_long (argc, argv, "i:o:", long_options, &option_index);
		if (c == -1)
			break;
		switch (c){
			case 0:
				break;
			case 'i':
				infile = optarg;
				break;
			default:
				exit (1);
		}
	}
	// open the point cloud, read all the points, and find the mode z value
	cout << infile << endl;
	split(strs, infile, is_any_of("."));
	assert(strs.size() == 2);
	string filename = strs.front();
	// make the directory
	mkdir(filename.c_str(), 0777);

	// read the point cloud
  	PointCloud<PointXYZ>::Ptr cloud (new PointCloud<PointXYZ>);
  	if ( pcl::io::loadPCDFile <PointXYZ> (infile, *cloud) == -1)
  	{
    		cout << "Cloud reading failed." << endl;
    		return (-1);
  	}
	
	ModelCoefficients::Ptr coefficients (new ModelCoefficients);
	PointIndices::Ptr inliers (new PointIndices);
	// Creates segmentation object
	SACSegmentation<PointXYZ> seg;
	seg.setOptimizeCoefficients(true);
	seg.setModelType(SACMODEL_PLANE);
	seg.setMethodType(SAC_RANSAC);
	seg.setDistanceThreshold(0.01);
	seg.setInputCloud(cloud);
	seg.segment(*inliers, *coefficients);
	
	// Planes
	if (inliers->indices.size() == 0){
		PCL_ERROR("Could not estimate a planar model for the given dataset.");
		return(-1);
	}
	cerr << "Model coefficients: " 	<< coefficients->values[0] << " "
					<< coefficients->values[1] << " "
					<< coefficients->values[2] << " "
					<< coefficients->values[3] << endl;
	cerr << "Model inliers: " << inliers->indices.size() << endl;

  	return (0);
}
