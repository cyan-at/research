load('/mnt/neocortex/scratch/norrathe/svn/libdeepnets/trunk/3dcar_detection/tmp/demo/obj1763.mat');
bbox = obj(1).bndbox;
imgobj= img(bbox(2):bbox(4),bbox(1):bbox(3),:);

trainedSvmPath = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment6/temp/temp_obj/model_kmeans_hard_hog_ps16_gs2_sz256_numHid128_pyr1_r0.01_imgW16_minN3_spin0.mat';
trainedUnsupPath = '/mnt/neocortex/scratch/3dproject/data/experiments/experiment6/temp/codebook/feature_codebook/kmeans_hard_hog_ps16_gs2_sz256_numHid128_pyr1_r0.01_imgW16_minN3_spin0.mat';

visualizeActivations2D(imgobj, 'hog', trainedUnsupPath, trainedSvmPath);
