function [] = plotSvmResults( svm, prec, rec, ap, msg)
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
    title(sprintf('%s AP = %.3f',msg,ap));
    print(h,'-djpeg',sprintf('%s/prec_rec_curve.jpg',svm.resultsPath));
end

