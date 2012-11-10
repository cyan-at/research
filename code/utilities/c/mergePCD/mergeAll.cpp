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
    // specify the options
    static struct option long_options[] = {
        {"infiles", required_argument, 0, 'i'},
        {"outfile", required_argument, 0, 'o'}
    };
    while (1){
        // getopt_long stores the option index here
        int option_index = 0;
        int c = getopt_long (argc, argv, "i:o:", long_options, &option_index);
        if (c == -1)
            break;
        switch (c){
            case 0:
                break;
            case 'i':
            {
                // cout << optarg << endl;
                vector<string> x = split(optarg, '_');
                // infiles->push(optarg);
                // cout << x.size() << endl;
                *infiles = x;
                break;       
            }
            case 'o':
                outfile = optarg;
                break;
            default:
                exit (1);
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