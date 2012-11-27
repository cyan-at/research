%experiment 2
extractTrainCarSource = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment2/mat/train/car';
extractTestCarSource = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment2/mat/test/car';

extractTrainCarTarget = '/mnt/neocortex/scratch/jumpbot/3dproject/data/experiments/experiment2/patches/train/car';
extractTestCarTarget = '/mnt/neocortex/scratch/jumpbot/3dproject/data/experiments/experiment2/patches/test/car';

extractTrainNegSource = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment2/mat/train/nonlap_negs';
extractTestNegSource = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment2/mat/test/nonlap_negs';

extractTrainNegTarget = '/mnt/neocortex/scratch/jumpbot/3dproject/data/experiments/experiment2/patches/train/nonlap_negs';
extractTestNegTarget = '/mnt/neocortex/scratch/jumpbot/3dproject/data/experiments/experiment2/patches/test/nonlap_negs';

%extractPatchesFromObjMat(extractTrainCarSource, extractTrainCarTarget, 1, true);
%extractPatchesFromObjMat(extractTestCarSource, extractTestCarTarget, 1, true);

%extractPatchesFromObjMat(extractTestNegSource, extractTestNegTarget, 1, false);
extractPatchesFromObjMat(extractTrainNegSource, extractTrainNegTarget, 1, false);





