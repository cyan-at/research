// merge multiple files
#include <pcl/point_types.h>
#include <pcl/io/pcd_io.h>
#include <iostream>
#include <fstream>
#include <string>
#include <getopt.h>
#include <vector>

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
    PointCloud<PointXYZ>::Ptr target (new PointCloud<PointXYZ>);
    while (!infiles->empty()){
        PointCloud<PointXYZ>::Ptr temp (new PointCloud<PointXYZ>);
        reader.read(infiles->back(), *temp);
        *target += *temp;
        infiles->pop_back();
    }
    stringstream ss;
    ss << outfile;
    PCDWriter writer;
    writer.write<PointXYZ> (ss.str (), *target, false);
    return 0;
}
