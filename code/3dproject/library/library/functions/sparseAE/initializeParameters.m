function theta = initializeParameters(num_ch, num_hid, patches, opt)
if ~exist('opt','var'), opt = 'tied'; end

if exist('patches','var') && ~isempty(patches),
    %% Initialize parameters via kmeans
    addpath /mnt/neocortex/scratch/kihyuks/library/kmeans/;
    if size(patches,2) == num_ch, patches = patches'; end
    [~,center] = kmeanspp(patches, num_hid, true, 100);
    W = center;
    if strcmp(opt,'untied'),
        W2 = W;
    end
    b = zeros(num_hid, 1);
    c = zeros(num_ch, 1);
else
    %% Initialize parameters randomly based on layer sizes.
    r  = sqrt(6) / sqrt(num_hid + num_ch + 1);
    W = rand(num_ch, num_hid) * 2 * r - r;
    if strcmp(opt,'untied'),
        W2 = rand(num_ch, num_hid) * 2 * r - r;
    end
    b = zeros(num_hid, 1);
    c = zeros(num_ch, 1);
end

if strcmp(opt,'untied'),
    theta = [W(:) ; W2(:) ; b(:) ; c(:)];
else
    theta = [W(:) ; b(:) ; c(:)];
end

return;

