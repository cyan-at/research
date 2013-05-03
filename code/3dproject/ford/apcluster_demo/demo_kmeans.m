% function test

load /mnt/neocortex/data/natural_images/vanHateren/whitened_lc_patches.mat
addpath /mnt/neocortex/scratch/jumpbot/libdeepnets/trunk/kmeans/fast_kmeans/
N=1000;
km = KMeans(N, true);
km.train(data);
W = km.centroids;
ws = sqrt(size(W,1));

%
D = zeros(N,N);

for i=1:N
    D(i,i) = 1;
end

for i=1:N
    if mod(i, 10)==0, fprintf('.'); end
    for j=i+1:N
        dist = maxcorr(W(:,i), W(:,j), ws);
        D(i,j) = dist;
        D(j,i) = dist;
    end
end

% return
% 1 - D

%Dist = (1-D);
%Dist(Dist>0.2) = 1;

Sim = D;
thres = quantile(D(:), 0.95);
Sim(Sim<thres) = 0;


% Hierarchical clustering

[idx,netsim,dpsim,expref]=apcluster(Sim,ones(N,1)*1/N);

[~, idx2] = sort(idx);
figure, display_network(W(:, idx2))
figure, display_network(W(:, unique(idx)));


