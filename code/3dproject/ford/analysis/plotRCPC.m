function plotRCPC( prec, rec, ap, desc, saveDir)
%PLOTSVMRESULTS Summary of this function goes here
%   Detailed explanation goes here
    h=figure;
    plot(rec,prec,'-');
    recName = sprintf('%s/rec.mat',saveDir);
    precName = sprintf('%s/prec.mat',saveDir);
    save(recName,'rec');
    save(precName,'prec');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    desc = strrep(desc, '_', ' ');
    title(sprintf('%s AP = %.3f',desc,ap));
    print(h,'-djpeg',sprintf('%s/plot.jpeg',saveDir));
end
