function [centers, label, label_proj] = tfkmeans_mult_filters_hard(X, k, opt_verbose, visualize, MAX_ITERS, randstate)
%%% TF-Kmeans-2 algorithm with power initialization
%   k-means++: The Advantages of Careful Seeding,
%   David Arthur, Sergei Vassilvitskii
%
%   X(data): num_ch x numsamples x num_tf
%   center : num_ch x k x num_tf_filters
if ~exist('opt_verbose', 'var'), opt_verbose = false; end;
if ~exist('MAX_ITERS', 'var'), MAX_ITERS = 100; end;
if ~exist('randstate', 'var'), randstate = 1; end;
if ~exist('num_tf_filters', 'var'), num_tf_filters = size(X,3); end;
if ~exist('visualize', 'var'), visualize = 0; end;
rand('state',randstate);

[num_ch, numsamples, num_tf] = size(X);

% Kmeans++ initialization
% center = zeros(num_ch, k, num_tf_filters);
% X_all = reshape(X,num_ch,numsamples*num_tf);
% if ~isempty(find(sum(X_all.^2) == 0, 1)), center(:,1) = zeros(num_ch,1); % initialize the all zero vector for the first center
% else center(:,1) = X_all(:,randi(size(X_all,2),1)); end % initialize with random data
% X_all = X_all(:,sum(X_all.^2) ~= 0); % remove all zero vectors since it won't help
% Dx2 = min(bsxfun(@plus,bsxfun(@minus,0.5*sum(X_all.^2,1),center(:,1)'*X_all),0.5*sum(center(:,1).^2,1)'),[],1);
% for i = 2:k,
%     % shortest distance from sample to cluster center already chosen
%     r = Dx2./sum(Dx2);
%     cumr = [0, cumsum(r)];
%     cumr = cumr(1:end-1);
%     id = sum(cumr < rand);
%     center(:,i) = X_all(:,id);
%     Dx2 = min(Dx2,bsxfun(@plus,bsxfun(@minus,0.5*sum(X_all.^2,1),center(:,i)'*X_all),0.5*sum(center(:,i).^2,1)'));
% end
% clear X_all;

% random initialization
centers = X(:,randsample(numsamples,k,numsamples<k),:);
X_all = reshape(X,num_ch,numsamples*num_tf);    % individual examples are considered as a separate example
% centers = reshape(X_all(:,randsample(numsamples*num_tf,k*num_tf_filters,numsamples*num_tf<k*num_tf_filters)),num_ch,k,num_tf_filters);
Xsq = sum(X_all.^2,1);
if visualize,
    for i = 1:num_tf_filters, figure(i); display_network_nonsquare(centers(:,:,i)); end
end

% E-step for cluster and transformation labels
itr=0;
last = 0;
b = ones(k*numsamples*num_tf,1);  % initial transformation clusters
center = centers(:,:,1);
dmin = bsxfun(@plus,Xsq,bsxfun(@minus,sum(single(center).^2,1)',2*single(center)'*X_all));    % k x (numsamples*num_tf)
for l = 2:num_tf_filters,
    center = centers(:,:,l);
    d = bsxfun(@plus,Xsq,bsxfun(@minus,sum(single(center).^2,1)',2*single(center)'*X_all));    % k x (numsamples*num_tf)
    [~,b_new] = min([dmin(:) d(:)],[],2);
    dmin = min(d,dmin);
    b(b_new == 2) = l;
end
d = sum(reshape(dmin,k,numsamples,num_tf),3);
[~,z] = min(d);
label = z(:);
b = reshape(b,k,numsamples,num_tf);
label_proj = zeros(numsamples,num_tf);
for i = 1:k,
    id = (z == i);
    label_proj(id,:) = b(i,id,:);
end
label = repmat(label,[num_tf,1]);       % cluster assignment
label_proj = label_proj(:);  % projection assignment

% MAX_ITERS=50;
while any(label ~= last)
    itr = itr+1;
    if opt_verbose, fprintf(1, '%d(%d)..', itr, sum(label ~= last)/num_tf); end
    
    % M-step
    for i = 1:num_tf_filters,
        idx = (label_proj == i);
        X_tmp = X_all(:,idx);
        label_tmp = label(idx);
        lnt = length(label_tmp);
        E = sparse(1:lnt,label_tmp,1,lnt,k,lnt);  % transform label into indicator matrix
        centers(:,:,i) = double(X_tmp)*(E*spdiags(1./sum(E,1)',0,k,k));    % compute center of each cluster
    end
    last = label;
    if visualize,
        for i = 1:num_tf_filters, figure(i); display_network_nonsquare(centers(:,:,i)); end
    end
    
    % E-step for cluster and transformation labels
    b = ones(k*numsamples*num_tf,1);  % initial transformation clusters
    center = centers(:,:,1);
    dmin = bsxfun(@plus,Xsq,bsxfun(@minus,sum(single(center).^2,1)',2*single(center)'*X_all));    % k x (numsamples*num_tf)
    for l = 2:num_tf_filters,
        center = centers(:,:,l);
        d = bsxfun(@plus,Xsq,bsxfun(@minus,sum(single(center).^2,1)',2*single(center)'*X_all));    % k x (numsamples*num_tf)
        [~,b_new] = min([dmin(:) d(:)],[],2);
        dmin = min(d,dmin);
        b(b_new == 2) = l;
    end
    d = sum(reshape(dmin,k,numsamples,num_tf),3);
    [~,z] = min(d);
    label = z(:);
    b = reshape(b,k,numsamples,num_tf);
    label_proj = zeros(numsamples,num_tf);
    for i = 1:k,
        id = (z == i);
        label_proj(id,:) = b(i,id,:);
    end
    label = repmat(label,[3,1]);       % cluster assignment
    label_proj = label_proj(:);  % projection assignment
    
    if (itr >= MAX_ITERS), break; end;
end
fprintf('\n');

return

