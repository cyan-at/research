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
	char* threshold_c = argv[3];
	float threshold = atof(threshold_c);
	char* passthrough_c = argv[4];
	float passthrough = atof(passthrough_c);
	char* passthrough2_c = argv[5];
	float passthrough2 = atof(passthrough2_c);

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
	PassThrough<PointFord> pass;  	pass.setInputCloud (cloud);  	pass.setFilterFieldName ("z");  	pass.setFilterLimits (passthrough,passthrough2);  	pass.setFilterLimitsNegative(true);  	pass.filter (*passed);

	cout << "Made cloud, now doing ransac" << endl;
	//ransac portion of code
	vector<int> inliers, outliers;
	PointIndices::Ptr inliersptr (new PointIndices());
	SampleConsensusModelPlane<PointFord>::Ptr groundmodel (new SampleConsensusModelPlane<PointFord> (passed));
	RandomSampleConsensus<PointFord> ransac (groundmodel);
	ransac.setDistanceThreshold(threshold);
	cout << "Computing model" << endl;
	ransac.computeModel();
	cout << "Getting inliers" << endl;
	ransac.getInliers(inliers);
	inliersptr->indices = inliers;
	int inliercount = inliers.size();
	cout << "Inliers found: " << inliercount << endl;

	cout << "Getting outliers" << endl;
	ExtractIndices<PointFord> extract;
	extract.setInputCloud(passed);
	extract.setIndices(inliersptr);    extract.setNegative(false);    extract.filter(*ground);
	extract.setNegative(true);
	extract.filter(*notground);
	cout << "Writing to not ground cloud" << endl;
	//write the final cloud to a file for visualization and processing	
	writer.write<PointFord> ((const char*)outfile_c, *passed, false);

	return 0;
}
