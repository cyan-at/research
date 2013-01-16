#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <boost/thread/thread.hpp>
#include "pcl/common/common_headers.h" 
#include "pcl/io/pcd_io.h" 
#include "pcl/visualization/pcl_visualizer.h" 
#include <pcl/visualization/point_picking_event.h>
#include <pcl/console/parse.h>
using namespace std;
static bool startRecording = false;
static string outfile = "";
static ofstream myfile;

string IntToStr(int i){
  ostringstream result;
  result << i;
  return result.str();
}

void write_index_to_file(int index){
	myfile << IntToStr(index) << endl;
}

void pp_callback (const pcl::visualization::PointPickingEvent& event, void* viewer_void) 
{ 
  //point pick callback, write the index to the file
  if (event.getPointIndex () == -1) 
  { 
    return; 
  } 
  float x, y, z;
  event.getPoint(x, y, z);
  cout << "index: " << event.getPointIndex() << endl;
  std::cout << x << " , " << y << " , " << z << endl;
  if (startRecording){
    cout << "recorded" << endl;
    write_index_to_file(event.getPointIndex());
  }
}

void keyboardEventOccurred (const pcl::visualization::KeyboardEvent &event, void* viewer_void)
{
  //press l to close the file, p to open the file, d to toggle recording
  if (event.getKeySym () == "l" && event.keyDown ())
  {
    std::cout << "l was pressed => closing " << outfile << std::endl;
    myfile.close();
  }
  else if (event.getKeySym() == "p" && event.keyDown()){
    cout << "p pressed => opening " << outfile << endl;
    myfile.open(outfile.c_str());
  }
  else if (event.getKeySym () == "d" && event.keyDown ())
  {
    std::cout << "d was pressed => recording toggled" << std::endl;
    startRecording = !startRecording;
  }
}
boost::shared_ptr<pcl::visualization::PCLVisualizer> interactionCustomizationVis (pcl::PointCloud<pcl::PointXYZRGB>::ConstPtr cloud) 
{ 
  boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer (new pcl::visualization::PCLVisualizer ("3D Viewer")); 
  viewer->setBackgroundColor (0, 0, 0); 
  viewer->addPointCloud<pcl::PointXYZRGB> (cloud, "sample cloud"); 
  viewer->setPointCloudRenderingProperties (pcl::visualization::PCL_VISUALIZER_POINT_SIZE, 1, "sample cloud"); 
  viewer->registerPointPickingCallback (pp_callback, (void*)&viewer); 
  viewer->registerKeyboardCallback(keyboardEventOccurred, (void*)&viewer);
  return (viewer);
} 
int main (int argc, char** argv) 
{

  //variables
  string infile = string(argv[1]);
  outfile = string(argv[2]);

  // Read in the cloud data
  pcl::PCDReader reader;
  pcl::PointCloud<pcl::PointXYZRGB>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZRGB>), cloud_f (new pcl::PointCloud<pcl::PointXYZRGB>);
  reader.read (infile, *cloud);
  
  //set some points to a certain color
  for (int i = 0; i < 1000; ++i){
  uint8_t r = 0;
  uint8_t g = 255;
  uint8_t b = 0;
  int32_t rgb = (r << 16) | (g << 8) | b;
  cloud->points[i].rgb = *(float *)(&rgb);
  }

  //visualize the points
  cloud->width = (int) cloud->points.size();
  cloud->height = 2; 
  boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer; 
  viewer = interactionCustomizationVis(cloud);
  while (!viewer->wasStopped ()) 
  { 
    viewer->spinOnce (100);
    boost::this_thread::sleep (boost::posix_time::microseconds (100000));
  }

  //open up the file
  string cmd = string("gedit ") + outfile;
  system (cmd.c_str());
  return 0;
} 
