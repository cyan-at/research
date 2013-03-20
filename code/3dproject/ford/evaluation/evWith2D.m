originalDir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset_multiple_scales/ford/batch_redo_train/results_afternms_redo_train_ver2/';
refineDir  = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/refine_3_20_13_1/';
%add paths
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
%add paths
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/
root = '/mnt/neocortex/scratch/jumpbot/data/3dproject/withlabels/test/';
refine = struct(); original = struct();
[refine.rec,refine.prec,refine.ap] = evalDetection(refineDir,root,0.5);
[original.rec,original.prec,original.ap] = evalDetection(originalDir,root,0.5);
%do plotting if needed
doplot = true;
if doplot
    %handle plotting!
    close all; figure; axis on; grid on; hold on;
    plot(original.rec,original.prec,'b');
    plot(refine.rec,refine.prec,'r');
    legend(...
        strcat('original: ap = ', num2str(original.ap)), ...
        strcat('refined: ap = ', num2str(refine.ap))...
        );
    title('refined vs. original');
    xlabel('recall'); ylabel('precision');
end