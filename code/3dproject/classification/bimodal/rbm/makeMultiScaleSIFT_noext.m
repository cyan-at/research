function tf_fea = makeMultiScaleSIFT_noext(pars,numsamples)

if ~exist('numsamples','var'), numsamples = 400000; end
database = makeDatabase(pars.dataname);
numimg = database.imnum;
clear database;
if ~isfield(pars,'num_ch'), pars.num_ch = pars.num_vis; end
    
if strcmp(pars.dataname,'caltech101'), sampleperimg = 80;
elseif strcmp(pars.dataname,'caltech256'), sampleperimg = 50; numsamples = 500000;
elseif strcmp(pars.dataname,'15scene'), sampleperimg = 150;
end
idx_select = randsample(numimg,ceil(1.2*numsamples/sampleperimg),numimg<ceil(1.2*numsamples/sampleperimg));
tf_fea = zeros(pars.num_ch*pars.es^2,numsamples,length(pars.ratio));

k = 0;
for j = 1:length(idx_select),
    try
        load(sprintf('%s/SIFT_%.6d.mat',pars.siftdatapath,idx_select(j)));
    catch
        continue;
    end
    if ~mod(j,1000), fprintf('.%d\n',j);
    elseif ~mod(j,10), fprintf('.'); end
    %     vector = macrofeature_patchgen_MS(feaSet,pars,sampleperimg);
    vector = feaSet.feaArr(:,randsample(size(feaSet.feaArr,2),sampleperimg,size(feaSet.feaArr,2)<sampleperimg),:);
    tf_fea(:,k+1:k+size(vector,2),:) = vector;
    k = k+size(vector,2);
    if k > numsamples, k = numsamples; break; end
end
fprintf('\n');
tf_fea = single(tf_fea(:,randsample(size(tf_fea,2),k),:));
end
