originalDir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train_test/results_afternms_redo_train/';
refineDir  = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/refine3_11_13_just_punish/';
%add paths
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
%add paths
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/
root = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test/';
refine = struct(); original = struct();
[pred_bbox gt refine.m refine.acc] = evalDetectionv2(refineDir,root);
[pred_bbox gt original.m original.acc] = evalDetectionv2(originalDir,root);
%do plotting if needed
doplot = true;
if doplot
    %handle plotting!
    close all; figure; axis on; grid on; hold on;
    plot(original.m.rc,original.m.pc,'b');
    plot(refine.m.rc,refine.m.pc,'r');
    legend('original','refine');
    title('refined (just punish) vs. original');
    xlabel('recall'); ylabel('precision');
end