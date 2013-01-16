function [centers, p, sig] = tgmm_mult_filters(X, K, opt_verbose, pinit, MAX_ITERS, unifsig, tkmeans_iter, newinit, visualize, randstate, dict_pre)
%%% T-GMM algorithm with power initialization
%
%   memory efficient version
%   K-means++: The Advantages of Careful Seeding,
%   David Arthur, Sergei Vassilvitskii
%
%   X(data): num_ch x num_samples x num_tf
%   center : num_ch x K x num_tf_filters
%   switching variables are w.r.t. filters and codeword
addpath ~/scratch/kihyuks/enceval-toolkit/tkmeans/;
maxNumCompThreads

if ~exist('opt_verbose', 'var') || isempty(opt_verbose), opt_verbose = false; end;
if ~exist('MAX_ITERS', 'var') || isempty(MAX_ITERS), MAX_ITERS = 100; end;
if ~exist('randstate', 'var') || isempty(randstate), randstate = 1; end;
if ~exist('num_tf_filters', 'var'), num_tf_filters = size(X,3); end;
if ~exist('visualize', 'var') || isempty(visualize), visualize = 0; end;
if ~exist('pinit', 'var') || isempty(pinit), pinit = 0; end;
if ~exist('batchsize', 'var'), batchsize = 40000; end;
if ~exist('newinit', 'var') || isempty(newinit), newinit = 0; end;
if ~exist('tkmeans_iter', 'var') || isempty(tkmeans_iter), tkmeans_iter = 0; end;
if ~exist('unifsig', 'var') || isempty(unifsig), unifsig = 0; end;
rand('state',randstate);

[num_ch, num_samples, num_tf] = size(X);
if batchsize > num_samples, batchsize = num_samples; end  % set the small batchsize to be num_samples if it is too large

%% Initialization via TKmeans
try
    load(dict_pre),
    if ~exist('centers','var'),
        centers = center;
        clear center;
    end
    newinit = 1;
catch
    [centers, label, label_proj] = tkmeans_mult_hard(X, K, opt_verbose, pinit, tkmeans_iter); % how much we want to pre-train via tkmeans
    if tkmeans_iter == 0, newinit = 1; end
end

% initialize prior
if newinit,
    p = 1/K*ones(K,1);
else
    E = sparse(1:num_samples,label,1,num_samples,K,num_samples)';
    p = mean(E,2);
    p = p + 1/num_samples;
    p = p/sum(p);
end

% initialize sigma
if newinit,
    center = reshape(centers,size(centers,1),size(centers,2)*size(centers,3));
    Xtmp = reshape(X,size(X,1),size(X,2)*size(X,3));
    [val,~] = min(bsxfun(@plus,sum(Xtmp.^2),bsxfun(@minus,sum(center.^2,1)',2*center'*Xtmp))); % assign samples to the nearest centers
    sig = repmat(sqrt(mean(val/num_ch)),num_tf_filters,1);
else
    sig = zeros(num_tf_filters,1);
    label = repmat(label,[num_tf_filters,1]);
    for j = 1:num_tf_filters,
        id = find(label_proj(:) == j);
        Xtmp = X(:,id);
        label_tmp = label(id);
        sig(j) = sum(sum((Xtmp - centers(:,label_tmp,j)).^2))/numel(Xtmp);
    end
end
clear Xtmp; clear E;

if visualize,
    figure;
    for i = 1:num_tf_filters,
        subplot(ceil(sqrt(num_tf_filters)),round(num_tf_filters/sqrt(num_tf_filters)),i);
        display_network_nonsquare(centers(:,:,i));
    end;
end
% if visualize, for i = 1:num_tf_filters, figure(i); display_network_nonsquare(centers(:,:,i)); end; end
fprintf('Centers initialized!\n');
fprintf('Training start!\n');

%% Training centers
% data reshaping
Xsq = sum(X.^2,1);  % 1 x num_samples x num_tf
num_iter = ceil(num_samples/batchsize);

% GMM
fprintf('Itr: ');
for itr = 1:MAX_ITERS,
    fprintf('%d.. ',itr);
    if unifsig, sig = repmat(sqrt(mean(sig.^2)),num_tf_filters,1); end
    p_new = zeros(size(p));
    centers_num = zeros(size(centers));
    centers_den = zeros(K,num_tf_filters);
    sig_num = zeros(num_tf_filters, 1);
    sig_den = zeros(num_tf_filters, 1);
    
    for j = 1:num_iter,
        %% E-step
        % batch index
        batchidx = (j-1)*batchsize+1:min(j*batchsize,num_samples);
        
        % current batch data
        Xbatch = reshape(X(:,batchidx,:),num_ch,length(batchidx)*num_tf);  % num_ch x (batchsize*num_tf)
        Xsq_batch = reshape(Xsq(:,batchidx,:),1,length(batchidx)*num_tf);
        nzid = Xsq_batch ~= 0;
        
        s = ones(K,sum(nzid));      % K x batchsize*num_tf, switching variable
        a = ones(K,sum(nzid));      % K x batchsize*num_tf, dummy
        center = centers(:,:,1);
        dmin = bsxfun(@plus,Xsq_batch(nzid),bsxfun(@minus,sum(center.^2,1)',2*center'*Xbatch(:,nzid)));    % K x (batchsize*num_tf)
        dmin = num_ch*log(sig(a)) + dmin.*(0.5./sig(a).^2);
        for l = 2:num_tf_filters,
            center = centers(:,:,l);
            d = bsxfun(@plus,Xsq_batch(nzid),bsxfun(@minus,sum(center.^2,1)',2*center'*Xbatch(:,nzid)));    % K x (batchsize*num_tf)
            d = num_ch*log(sig(a*l)) + d.*(0.5./sig(a*l).^2);
            [~,s_new] = min([dmin(:) d(:)],[],2);
            dmin = min(d,dmin);
            s(s_new == 2) = l;
        end
        d = zeros(K,length(batchidx)*num_tf);
        d(:,nzid) = dmin;
        d = -sum(reshape(d,K,length(batchidx),num_tf),3);
        d = bsxfun(@minus,d,max(d));
        pz = bsxfun(@rdivide,bsxfun(@times,p,exp(d)),p'*exp(d)); % K x batchsize, p(z_k|v)
        
        %% M step
        p_new = p_new + sum(pz,2);
        pz_rep = repmat(pz,[1,num_tf]);
        for k = 1:K,
            for t = 1:num_tf_filters,
                idx = (s(k,:) == t);
                X_tmp = Xbatch(:,idx);
                z_kt = pz_rep(k,idx)';
                centers_num(:,k,t) = centers_num(:,k,t) + X_tmp*z_kt;
                centers_den(k,t) = centers_den(k,t) + sum(z_kt);
                sig_num(t) = sig_num(t) + sum(bsxfun(@minus, X_tmp, centers(:,k,t)).^2*z_kt);   % issue in batch update...
                sig_den(t) = sig_den(t) + num_ch*sum(z_kt);
            end
        end
    end
    
    % update parameters
    p = p_new/num_samples;
    centers_den = centers_den + 1e-3; % for numerical stability
    centers = centers_num./repmat(permute(centers_den,[3 1 2]),[num_ch,1,1]);
    sig = sqrt(sig_num./sig_den);
    if visualize,
        figure(100);
        for i = 1:num_tf_filters,
            subplot(ceil(sqrt(num_tf_filters)),round(num_tf_filters/sqrt(num_tf_filters)),i);
            display_network_nonsquare(centers(:,:,i));
        end;
    end
end

if unifsig, sig = repmat(sqrt(mean(sig.^2)),num_tf_filters,1); end

fprintf('DONE!\n');
return



