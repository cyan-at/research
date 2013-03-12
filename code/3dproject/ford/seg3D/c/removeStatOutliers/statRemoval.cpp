#include <iostream>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/filters/statistical_outlier_removal.h>
#include <fstream>
#include <string>
#include <getopt.h>
#include "/mnt/neocortex/scratch/jumpbot/research/code/3dproject/segmentation/ford/c/PointFord.h"
using namespace pcl;
using namespace std;

int main (int argc, char** argv)
{
  //argument parsing
  string infile;
  string outfile;
  static struct option long_options[] = {
	{"infile", required_argument, 0, 'i'},
	{"outfile",required_argument, 0, 'o'} 
  };  
  while(1){
	// getopt_long stores the option index here
	int option_index = 0;
	int c = getopt_long(argc, argv, "i:o:", long_options, &option_index);
	if (c == -1)
		break;
	switch(c){
		case 0:
			break;
		case 'i':
		{
			infile = optarg;
			break;
		}
		case 'o':
		{
			outfile = optarg;
			break;
		}
		default:
			exit(1);
	}
  }
  pcl::PointCloud<PointFord>::Ptr cloud (new pcl::PointCloud<PointFord>);
  pcl::PointCloud<PointFord>::Ptr cloud_filtered (new pcl::PointCloud<PointFord>);
  // Fill in the cloud data
  pcl::PCDReader reader;
  // Replace the path below with the path where you saved your file
  reader.read<PointFord> (infile, *cloud);
  // Create the filtering object
  pcl::StatisticalOutlierRemoval<PointFord> sor;
  sor.setInputCloud (cloud);
  sor.setMeanK (50);
  sor.setStddevMulThresh (1.0);
  sor.filter (*cloud_filtered);
  pcl::PCDWriter writer;
  writer.write<PointFord> (outfile, *cloud_filtered, false);
  return (0);
}
