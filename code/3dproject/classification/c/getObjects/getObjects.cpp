#include <pcl/point_types.h>
#include <pcl/io/pcd_io.h>
#include <pcl/common/point_operators.h>
#include <pcl/common/io.h>
#include <pcl/io/vtk_io.h>
#include <pcl/filters/crop_box.h>

#include <iostream>
#include <fstream>
#include <string>
#include <getopt.h>
#include "tracklets.h"

using namespace pcl;
using namespace std;

int main(int argc, char **argv){
	///The file to read from.
	string infile;

	///The file to read tracklets from.
	string trackletfile;

	///The file to output to.
	string outfile;

	///The object type to extract
	string objtype;

	///The kitti frame id
	int frameid;

	static struct option long_options[] = {
		{"infile", required_argument, 0, 'i'},
		{"outfile", required_argument, 0, 'o'},
		{"trackletfile", required_argument, 0, 't'},
		{"type", required_argument, 0, 'y'},
		{"frameid", required_argument, 0, 'f'}
	};
	while (1){
		// getopt_long stores the option index here
		int option_index = 0;
		int c = getopt_long (argc, argv, "i:o:t:y:f:", long_options, &option_index);
		if (c == -1)
			break;
		switch (c){
			case 0:
				break;
			case 'i':
				infile = optarg;
				break;
			case 'o':
				outfile = optarg;
				break;
			case 't':
				trackletfile = optarg;
				break;
			case 'y':
				objtype = optarg;
				break;
			case 'f':
				frameid = atoi(optarg);
				break;
			default:
				exit (1);
		}
	}

	Tracklets *tracklets = new Tracklets();
	if (!tracklets->loadFromFile(trackletfile)){
		cerr << "Could not read tracklets file: " << trackletfile << endl;
	}

	// Load cloud in blob format
	sensor_msgs::PointCloud2 blob;
	pcl::io::loadPCDFile (infile.c_str(), blob);

	pcl::PointCloud<PointXYZI>::Ptr cloud (new pcl::PointCloud<PointXYZI>);
	cout << "Loading point cloud...";
	pcl::fromROSMsg (blob, *cloud);
	cout << "done." << endl;

	pcl::CropBox<PointXYZI> clipper;
	clipper.setInputCloud(cloud);

	pcl::PCDWriter writer;
	pcl::PointCloud<PointXYZI>::Ptr outcloud;

	//For each tracklet, extract the points
	for(int i = 0; i < tracklets->numberOfTracklets(); i++){
		if(!tracklets->isActive(i,frameid)){
			continue;
		}
		Tracklets::tTracklet* tracklet = tracklets->getTracklet(i);
		if(objtype.empty() || tracklet->objectType == objtype){
			Tracklets::tPose *pose;
			if(tracklets->getPose(i, frameid, pose)){
				outcloud.reset(new pcl::PointCloud<PointXYZI>);
				cout << "Pose rx" << pose->rx << endl;
				cout << "Pose ry" << pose->ry << endl;
				cout << "Pose rz" << pose->rz << endl;
				cout << "Pose tx" << pose->tx << endl;
				cout << "Pose ty" << pose->ty << endl;
				cout << "Pose tz" << pose->tz << endl;

			}
		}

	}

    delete tracklets;
}
