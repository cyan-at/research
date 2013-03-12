originalDir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train_test/results_afternms_redo_train/';
refineDir  = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/refine3_11_13_just_punish/';
refineDir2  = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/refine3_11_13/';
%add paths
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
%add paths
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/
root = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test/';
refine = struct(); original = struct();
[refine.rec,refine.prec,refine.ap] = evalDetectionv2(refineDir,root);
[refine2.rec,refine2.prec,refine2.ap] = evalDetectionv2(refineDir2,root);
[original.rec,original.prec,original.ap] = evalDetectionv2(originalDir,root);
%do plotting if needed
doplot = true;
if doplot
    %handle plotting!
    close all; figure; axis on; grid on; hold on;
    plot(original.rec,original.prec,'b');
    plot(refine.rec,refine.prec,'r');
    plot(refine2.rec,refine2.prec,'c');
    legend(...
        strcat('original: ap = ', num2str(original.ap)), ...
        strcat('refined: ap = ', num2str(refine.ap)),...
        strcat('refined2: ap = ', num2str(refine2.ap))...
        );
    title('refined (just punish) vs. original');
    xlabel('recall'); ylabel('precision');
end