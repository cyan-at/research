#include <iostream>
#include <vector>
#include <pcl/point_types.h>
#include <pcl/io/pcd_io.h>
#include <pcl/search/search.h>
#include <pcl/search/kdtree.h>
#include <pcl/features/normal_3d.h>
#include <pcl/visualization/cloud_viewer.h>
#include <pcl/filters/passthrough.h>
#include <pcl/segmentation/region_growing.h>
#include <iostream>
#include <fstream>
#include <string>
#include <getopt.h>

using namespace std;


int main (int argc, char** argv)
{
	///The file to read from.
	string infile;
	string outDir;
	// hyperparameters
	int k = 10;
	int r = 10;
	int m = 10;
	int a = 10;
	// specify the options
	static struct option long_options[] = {
		{"infile", required_argument, 0, 'i'},
		{"outdir", required_argument, 0, 'o'},
		{"ksearch", required_argument, 0, 'k'},
		{"numberNeighbors", required_argument, 0, 'r'},
		{"min", required_argument, 0, 'm'},
		{"max", required_argument, 0, 'a'}
	};
	while (1){
		// getopt_long stores the option index here
		int option_index = 0;
		int c = getopt_long (argc, argv, "i:o:k:r:m:a:", long_options, &option_index);
		if (c == -1)
			break;
		switch (c){
			case 0:
				break;
			case 'i':
				infile = optarg;
				break;
			case 'o':
				outDir = optarg;
				break;
			case 'k':
				k = atoi(optarg);
				break;
			case 'r':
				r = atoi(optarg);
				break;
			case 'm':
				m = atoi(optarg);
				break;
			case 'a':
				a = atoi(optarg);
				break;
			default:
				exit (1);
		}
	}
  pcl::PointCloud<pcl::PointXYZ>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZ>);
  if ( pcl::io::loadPCDFile <pcl::PointXYZ> (infile, *cloud) == -1)
  {
    std::cout << "Cloud reading failed." << std::endl;
    return (-1);
  }
 
  pcl::search::Search<pcl::PointXYZ>::Ptr tree = boost::shared_ptr<pcl::search::Search<pcl::PointXYZ> > (new pcl::search::KdTree<pcl::PointXYZ>);
  pcl::PointCloud <pcl::Normal>::Ptr normals (new pcl::PointCloud <pcl::Normal>);
  pcl::NormalEstimation<pcl::PointXYZ, pcl::Normal> normal_estimator;
  normal_estimator.setSearchMethod (tree);
  normal_estimator.setInputCloud (cloud);
  normal_estimator.setKSearch (k);
  normal_estimator.compute (*normals);

  pcl::IndicesPtr indices (new std::vector <int>);
  pcl::PassThrough<pcl::PointXYZ> pass;
  pass.setInputCloud (cloud);
  pass.setFilterFieldName ("z");
  pass.setFilterLimits (0.0, 1.0);
  pass.filter (*indices);

  pcl::RegionGrowing<pcl::PointXYZ, pcl::Normal> reg;
  reg.setMinClusterSize (m);
  reg.setMaxClusterSize (a);
  reg.setSearchMethod (tree);
  reg.setNumberOfNeighbours (r);
  reg.setInputCloud (cloud);
  reg.setInputNormals (normals);
  reg.setSmoothnessThreshold (7.0 / 180.0 * M_PI);
  reg.setCurvatureThreshold (1.0);

  std::vector <pcl::PointIndices> clusters;
  reg.extract (clusters);

  //std::cout << "Number of clusters is equal to " << clusters.size () << std::endl;
  pcl::PCDWriter writer;
  unsigned int j = 0;
  int total = 0;
  for (std::vector<pcl::PointIndices>::const_iterator it = clusters.begin (); it != clusters.end (); ++it)
  {
    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_cluster (new pcl::PointCloud<pcl::PointXYZ>);
    for (std::vector<int>::const_iterator pit = it->indices.begin (); pit != it->indices.end (); pit++)
      cloud_cluster->points.push_back (cloud->points[*pit]); //*
    cloud_cluster->width = cloud_cluster->points.size ();
    cloud_cluster->height = 1;
    cloud_cluster->is_dense = true;
    
    total += cloud_cluster->points.size();

    //std::cout << "PointCloud representing the Cluster: " << cloud_cluster->points.size () << " data points." << std::endl;
    std::stringstream ss;
    ss << outDir << j << ".pcd";
    cout << ss.str() << endl;
    writer.write<pcl::PointXYZ> (ss.str (), *cloud_cluster, false); //*
    j++;
  }
  cout << total << endl;


  return (0);
}
