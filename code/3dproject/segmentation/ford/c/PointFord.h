#include <pcl/point_types.h>
#include <pcl/point_cloud.h>
#include <pcl/io/pcd_io.h>
#include <pcl/filters/statistical_outlier_removal.h>
#include <pcl/filters/impl/statistical_outlier_removal.hpp>
#include <pcl/search/organized.h>
#include <pcl/search/impl/organized.hpp>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/kdtree/impl/kdtree_flann.hpp>
#include <pcl/segmentation/extract_clusters.h>
#include <pcl/segmentation/impl/extract_clusters.hpp>
//for ransac
#include <pcl/sample_consensus/ransac.h>
#include <pcl/sample_consensus/impl/ransac.hpp>
#include <pcl/sample_consensus/sac_model_plane.h>
#include <pcl/sample_consensus/impl/sac_model_plane.hpp>
#include <pcl/filters/extract_indices.h>
#include <pcl/filters/impl/extract_indices.hpp>

struct PointFord{
   PCL_ADD_POINT4D;
   unsigned int rgb;
   float r;
   float g;
   float b;
   float pixelx;
   float pixely;
   float cam;
   float scan;
   EIGEN_MAKE_ALIGNED_OPERATOR_NEW   
} EIGEN_ALIGN16;

POINT_CLOUD_REGISTER_POINT_STRUCT (PointFord,
	(float, x, x)
	(float, y, y)
	(float, z, z)
	(unsigned int, rgb, rgb)
	(float, r, r)
	(float, g, g)
	(float, b, b)
	(float, pixelx, pixelx)
	(float, pixely, pixely)
	(float, cam, cam)
	(float, scan, scan)
	)
