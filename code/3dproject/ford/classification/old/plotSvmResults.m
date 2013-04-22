function [] = plotSvmResults( svm, prec, rec, ap )
%PLOTSVMRESULTS Summary of this function goes here
%   Detailed explanation goes here
    h=figure;
    plot(rec,prec,'-');
    recName = sprintf('%s/rec.mat',svm.resultsPath);
    precName = sprintf('%s/prec.mat',svm.resultsPath);
    save(recName,'rec');
    save(precName,'prec');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: cars, AP = %.3f',ap));
    print(h,'-djpeg',sprintf('%s/prec_rec_curve.jpg',svm.resultsPath));
end

