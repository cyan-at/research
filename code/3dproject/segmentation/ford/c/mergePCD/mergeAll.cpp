// merge multiple files
#include <pcl/point_types.h>
#include <pcl/io/pcd_io.h>
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

int main (int argc, char** argv){
    ///The file to read from.
    vector<string>* infiles = new vector<string>;
    string outfile;
    vector<string> v(argv, argv+argc);
    //cout << v.size() << endl;
    for (int i = 1; i < v.size(); ++i){
        if (i < v.size()-2){
            //cout << "inputs: " << v.at(i) << endl;
            infiles->push_back(v.at(i));
        }
        else if (i == v.size()-1){
            //cout << "outputs: " << v.at(i) << endl;
            outfile = v.at(i);
        }
    }
    // cout << infiles->size() << endl;
    PCDReader reader;
    PointCloud<PointFord>::Ptr target (new PointCloud<PointFord>);
    while (!infiles->empty()){
        PointCloud<PointFord>::Ptr temp (new PointCloud<PointFord>);
        reader.read(infiles->back(), *temp);
        *target += *temp;
        infiles->pop_back();
    }
    stringstream ss;
    ss << outfile;
    PCDWriter writer;
    writer.write<PointFord> (ss.str (), *target, false);
    return 0;
}
