originalDir = '/mnt/neocortex/scratch/norrathe/data/car_patches/multiple_filters/batch/test_results/';
%add paths
researchPath = '/mnt/neocortex/scratch/jumpbot/research/code/3dproject/';
addpath(genpath(strcat(researchPath,'/library/')));
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/detection/
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/3dcar_detection/cnn/

[original.rec,original.prec,original.ap] = evalDetection(originalDir,root,0.5);
%do plotting if needed
doplot = true;
if doplot
    %handle plotting!
    close all; figure; axis on; grid on; hold on;
    plot(original.rec,original.prec,'b');
    legend(...
        strcat('original: ap = ', num2str(original.ap)) ...
        );
    title('before nms');
    xlabel('recall'); ylabel('precision');
end