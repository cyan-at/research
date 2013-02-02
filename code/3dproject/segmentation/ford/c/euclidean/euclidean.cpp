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
#include "/mnt/neocortex/scratch/jumpbot/research/code/3dproject/segmentation/ford/c/PointFord.h"

using namespace pcl;
using namespace std;

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
  std::cout << "PointCloud before filtering has: " << cloud->points.size () << " data points." << std::endl; //*

  // Creating the KdTree object for the search method of the extraction
  pcl::search::KdTree<PointFord>::Ptr tree (new pcl::search::KdTree<PointFord>);
  tree->setInputCloud (cloud);

  std::vector<pcl::PointIndices> cluster_indices;
  pcl::EuclideanClusterExtraction<PointFord> ec;
  ec.setClusterTolerance (h); // 2cm
  ec.setMinClusterSize (50);
  ec.setMaxClusterSize (100000);
  ec.setSearchMethod (tree);
  ec.setInputCloud (cloud);
  ec.extract (cluster_indices);

  int j = 0;
  for (std::vector<pcl::PointIndices>::const_iterator it = cluster_indices.begin (); it != cluster_indices.end (); ++it)
  {
    pcl::PointCloud<PointFord>::Ptr cloud_cluster (new pcl::PointCloud<PointFord>);
    for (std::vector<int>::const_iterator pit = it->indices.begin (); pit != it->indices.end (); pit++)
      cloud_cluster->points.push_back (cloud->points[*pit]); //*
    cloud_cluster->width = cloud_cluster->points.size ();
    cloud_cluster->height = 1;
    cloud_cluster->is_dense = true;

    std::cout << "PointCloud representing the Cluster: " << cloud_cluster->points.size () << " data points." << std::endl;
    std::stringstream ss;
    ss << outDir << j << ".pcd";
    writer.write<PointFord> (ss.str (), *cloud_cluster, false); //*
    j++;
  }

  return (0);
}
