// Input: tracklet file location
// Input: cars.pcd, nots.pcd file locations
// Input: identifier for frame within the tracklet
// The point cloud is the DON filtered, post classification file

// Routine:
// Scan through the tracklet file picking up every object in the original 
// point cloud
// For each car object found in this point cloud, look at that location
// within cars.pcd, within nots.pcd
// If the count for the filtered out from cars.pcd is 0, then it wasn't
// clustered
// Otherwise, the clustering + classification successfully labeled the car

int main(){
    
    return 0;
}