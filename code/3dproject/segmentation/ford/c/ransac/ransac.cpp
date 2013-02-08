#include <iostream>
#include <fstream>
#include <string>
#include <getopt.h>
#include <vector>
#include <pcl/console/parse.h>
#include <pcl/filters/extract_indices.h>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/sample_consensus/ransac.h>
#include <pcl/sample_consensus/sac_model_plane.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <boost/thread/thread.hpp>
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
 	PointCloud<PointFord>::Ptr cloud (new PointCloud<PointFord>), final (new PointCloud<PointFord>);
  	reader.read (infile, *cloud);
	cout << "Made cloud, now doing ransac" << endl;

	//ransac portion of code
	vector<int> inliers;
	SampleConsensusModelPlane<PointFord>::Ptr groundmodel (new SampleConsensusModelPlane<PointFord> (cloud));
	RandomSampleConsensus<PointFord> ransac (groundmodel);
	ransac.setDistanceThreshold(0.01);
	cout << "Computing model" << endl;
	ransac.computeModel();
	cout << "Getting inliers" << endl;
	ransac.getInliers(inliers);

	cout << "Writing to output cloud" << endl;
	//copy inliers to final cloud
	copyPointCloud<PointFord>(*cloud,inliers,*final);
	//write the final cloud to a file for visualization and processing	
	writer.write<PointFord> ((const char*)outfile_c, *final, false);

	return 0;
}
