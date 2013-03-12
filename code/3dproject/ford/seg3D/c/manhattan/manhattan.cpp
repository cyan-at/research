#include <iostream>
#include <fstream>
#include <string>
#include <getopt.h>
#include <vector>
#include <pcl/console/parse.h>
#include <pcl/filters/filter.h>
#include <pcl/filters/extract_indices.h>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/sample_consensus/ransac.h>
#include <pcl/sample_consensus/sac_model_plane.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <boost/thread/thread.hpp>
#include <pcl/filters/passthrough.h>
#include "/mnt/neocortex/scratch/jumpbot/research/code/3dproject/segmentation/ford/c/PointFord.h"

using namespace pcl;
using namespace std;

int main (int argc, char** argv){
	///The file to read from, the one after remove outliers
	
	//if not enough parameters, return
	if (argc < 3)
		return 0;

	//grab the arguments
	char* infile_c = argv[1];
	char* outfile_c = argv[2];
	string infile = string(infile_c);

	//read the input file into a cloud of pointfords
	PCDReader reader;
 	PCDWriter writer;
 	PointCloud<PointFord>::Ptr cloud (new PointCloud<PointFord>);
	PointCloud<PointFord>::Ptr passed (new PointCloud<PointFord>);
	PointCloud<PointFord>::Ptr ground (new PointCloud<PointFord>);
	PointCloud<PointFord>::Ptr notground (new PointCloud<PointFord>);
  	reader.read (infile, *cloud);

	//passthrough filter to get points, -3.5 to -2.2
	cout << "pass through" << endl;
	PassThrough<PointFord> pass;
  	pass.setInputCloud (cloud);
  	pass.setFilterFieldName ("z");
  	pass.setFilterLimits (-3.5,-2.2);
  	pass.setFilterLimitsNegative(true);
  	pass.filter (*passed);

	//write the final cloud to a file for visualization and processing	
	writer.write<PointFord> ((const char*)outfile_c, *passed, false);

	return 0;
}
