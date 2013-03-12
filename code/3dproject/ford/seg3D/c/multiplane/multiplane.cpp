#include <pcl/ModelCoefficients.h>
#include <pcl/point_types.h>
#include <pcl/io/pcd_io.h>
#include <pcl/filters/extract_indices.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/features/normal_3d.h>
#include <pcl/kdtree/kdtree.h>
#include <pcl/sample_consensus/method_types.h>
#include <pcl/sample_consensus/model_types.h>
#include <pcl/segmentation/sac_segmentation.h>
#include <pcl/segmentation/extract_clusters.h>
#include <iostream>
#include <fstream>
#include <string>
#include <getopt.h>
#include <vector>
#include "/mnt/neocortex/scratch/jumpbot/research/code/3dproject/segmentation/ford/c/PointFord.h"

using namespace pcl;
using namespace std;

vector<string>& split(const string &s, char delim, vector<string> &elems){  
    stringstream ss(s);
    string item;
    while (getline(ss, item, delim)){
        elems.push_back(item);
    }
    return elems;
}

vector<string> split(const string &s, char delim){
    vector<string> elems;
    return split(s, delim, elems);
}

int main (int argc, char** argv)
{
	///The file to read from.
	string infile;
	string outDir;
	float h;
	// specify the options
	static struct option long_options[] = {
		{"infile", required_argument, 0, 'i'},
		{"distance", required_argument, 0, 'd'},
		{"outdir", required_argument, 0, 'o'}
	};
	while (1){
		// getopt_long stores the option index here
		int option_index = 0;
		int c = getopt_long (argc, argv, "i:d:o:", long_options, &option_index);
		if (c == -1)
			break;
		switch (c){
			case 0:
				break;
			case 'i':
				infile = optarg;
				break;
			case 'd':
        h = atof(optarg);
				break;
			case 'o':
				outDir = optarg;
				break;
			default:
				exit (1);
		}
	}
  // Read in the cloud data
  pcl::PCDReader reader;
  pcl::PCDWriter writer;
  pcl::PointCloud<PointFord>::Ptr cloud (new pcl::PointCloud<PointFord>), cloud_f (new pcl::PointCloud<PointFord>);
  reader.read (infile, *cloud);

  return (0);
}
