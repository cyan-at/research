function [label,center] = kmeanspp(X, k, opt_verbose, MAX_ITERS)
%%% Kmeans++ algorithm
%   k-means++: The Advantages of Careful Seeding,
%   David Arthur, Sergei Vassilvitskii
%
%   X(data): num_ch x numsamples
%   center : num_ch x k
if ~exist('opt_verbose', 'var'), opt_verbose = false; end
if ~exist('MAX_ITERS', 'var'), MAX_ITERS = 50; end
[num_ch, numsamples, ~] = size(X);

% Kmeans++ initialization
center = zeros(num_ch, k);
center(:,1) = X(:,randi(numsamples,1));
Dx2 = min(bsxfun(@plus,bsxfun(@minus,0.5*sum(X.^2,1),center(:,1)'*X),0.5*sum(center(:,1).^2,1)'),[],1);
for i = 2:k,
    % shortest distance from sample to cluster center already chosen
    r = Dx2./sum(Dx2);
    cumr = [0, cumsum(r)];
    cumr = cumr(1:end-1);
    id = sum(cumr < rand);
    center(:,i) = X(:,id);
    Dx2 = min(Dx2,bsxfun(@plus,bsxfun(@minus,0.5*sum(X.^2,1),center(:,i)'*X),0.5*sum(center(:,i).^2,1)'));
end

% E-step
last = 0;
[~,label] = max(bsxfun(@minus,center'*X,0.5*sum(center.^2,1)')); % assign samples to the nearest centers
itr=0;

while any(label ~= last)
    itr = itr+1;
    if opt_verbose, fprintf(1, '%d(%d)..', itr, sum(label ~= last)); end
    % M-step
    E = sparse(1:numsamples,label,1,numsamples,k,numsamples);  % transform label into indicator matrix
    center = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute center of each cluster
    last = label;
    
    % E-step
    [~,label] = max(bsxfun(@minus,center'*X,0.5*sum(center.^2,1)')); % assign samples to the nearest centers
    if (itr >= MAX_ITERS), break; end;
end

if opt_verbose, fprintf(1,'\n'); end
return;

