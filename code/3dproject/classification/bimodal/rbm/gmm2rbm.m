function [RBM sigmagmm GMM KM] = gmm2rbm(fea_all, opt_iterations, pars)
% This code will use GMM with sigma0*I covariances
% The likelihood can be written as
% P(x|model) = \sum_k p0_k Normal(x|mu_k, sigma0 I)
%            \propto \sum_k p0_k exp( - ||x - mu_k||^2/(2 sigma0^2) )
% GMM is trained after Kmeans initialization, followed by EM algorithm

maxNumCompThreads(8)
if ~exist('opt_iterations', 'var'), opt_iterations = 10; end
if ~isfield(pars,'opttfinit'), pars.opttfinit = 0; end

fea_all = fea_all(:,randperm(size(fea_all,2)));
% fea_all = double(fea_all);

addpath /mnt/neocortex/scratch/kihyuks/enceval-toolkit/tkmeans/;

if pars.opttfinit,
    addpath /mnt/neocortex/scratch/kihyuks/libdeepnets/trunk/transform_clustering/;
    Tlist = get_projection(pars.es,pars.ws,1,pars.num_vis);
    [center, label, label_proj] = train_tf_kmeans_for_sift(fea_all, pars.num_hid, Tlist, true, 250, 1);
    X_proj = sample_projection(fea_all,Tlist,label_proj);    % output is in single format
    sigma0 = sqrt(mean(mean( (X_proj - center(:, label)).^2, 2))); % Using sigma0*I in this example
    clear X_proj;
    opt_iterations = 0;
else
    fea_all = double(fea_all);
    [label, center] = kmeanspp(fea_all,pars.num_hid, true, 250);
    fea_all = single(fea_all);
    sigma0 = sqrt(mean(mean( (fea_all - center(:, label)).^2, 2))); % Using sigma0*I in this example
end
KM.center = center;

% initialize GMMs
n = size(fea_all,2);
E = sparse(1:n,label,1,n,pars.num_hid,n)';  % transform label into indicator matrix

% initial GMM paramters
p0 = mean(E,2);
p0 = p0 + 1/size(fea_all,2);
p0 = p0/sum(p0);
% p0 = sparse(p0);
mu0 = center;

fea_all = single(fea_all);
% GMM iterations
for t=1:opt_iterations
    fprintf('GMM iteration: %g...\n', t);
    
    % E step
    distsq = bsxfun(@minus,mu0'*fea_all, 0.5*sum(mu0.^2,1)');
    distsq = bsxfun(@minus,distsq, 0.5*sum(fea_all.^2,1));
    distsq = bsxfun(@minus, distsq, max(distsq)); % this for a numerical stability
    distsq = exp(bsxfun(@plus, distsq./2/sigma0^2, log(p0)));
    distsq = bsxfun(@rdivide, distsq, sum(distsq)); % softmax
    
    % M step
    p0 = mean(distsq,2);
    mu0 = zeros(size(mu0));
    errvecsq_total = 0;
    z_total = 0;
    for k=1:pars.num_hid
        z_k = distsq(k,:)';
        mu_k = fea_all*z_k/sum(z_k);
        mu0(:,k) = mu_k;
        
        errvecsq_total = errvecsq_total + bsxfun(@minus, fea_all, mu_k).^2*z_k;
        z_total = z_total + sum(z_k);
    end
    sigma0 = sqrt(mean(errvecsq_total/sum(z_total)));
end


%% Initialize RBM parameters
GMM.p0 = p0;
GMM.mu = mu0;
GMM.sigma = sigma0;

c = GMM.mu*GMM.p0;
sigmagmm = GMM.sigma;
Wgmm = bsxfun(@minus, GMM.mu, c)./sigmagmm;

bgmm = zeros(length(GMM.p0),1);

% heuristic..
for k = 1:length(GMM.p0)
    bgmm(k) = sigmagmm*log(GMM.p0(k)*pars.num_hid)-Wgmm(:,k)'*(sigmagmm/2*Wgmm(:,k)+c);
end
% c = reshape(c,[pars.num_vis,pars.ws^2]);

RBM.W = Wgmm;
RBM.vbias = c;
RBM.hbias = bgmm(:);

return
