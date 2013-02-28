clear CARopts

% get current directory with forward slashes
cwd=CARDIR;
cwd(cwd=='\')='/';
CARopts.dataset = 'data';
% change this path to point to your copy of the CAR data
CARopts.datadir=[cwd];

% change this path to a writable directory for your results
CARopts.resdir='results/';

% change this path to a writable local directory for the example code
CARopts.localdir='local/';

% initialize the test set
% CARopts.testset='val'; % use validation data for development test set
CARopts.testset='test'; % use test set for final challenge

% initialize main challenge paths
CARopts.annopath=[CARopts.datadir CARopts.dataset '/xml/Annotations/%s.xml'];
CARopts.imgpath=[CARopts.datadir  CARopts.dataset '/xml/JPEGImages/%s.jpg'];
CARopts.imgsetpath=[CARopts.datadir CARopts.dataset '/xml/ImageSets/%s.txt'];
CARopts.clsimgsetpath=[CARopts.datadir CARopts.dataset '/xml/ImageSets/%s_%s.txt'];

CARopts.detrespath=['/mnt/neocortex/scratch/norrathe/codes/toyota_detection/results/%s_det_' CARopts.testset '_%s.txt'];

CARopts.nclasses=1;
CARopts.poses={'Frontal'};
CARopts.nposes=length(CARopts.poses);
CARopts.parts={...
    'head'
    'hand'
    'foot'};
CARopts.maxparts=[1 2 2];   % max of each of above parts
CARopts.nparts=length(CARopts.parts);
CARopts.minoverlap=0.5;

% initialize example options
CARopts.exannocachepath=[CARopts.localdir '%s_anno.mat'];
CARopts.exfdpath=[CARopts.localdir '%s_fd.mat'];
