posIdx = 1;
negIdx = 1;
root_dir = '/mnt/neocortex/scratch/norrathe/data/car_patches/cnn_dataset/test_patches';
pos_dir = fullfile(root_dir,'pos');
neg_dir = fullfile(root_dir,'neg');
for i=1:length(test_IMAGES)
    [pos, neg] = extract_posneg(test_IMAGES{i},filter_size,10,100,test_gt(i),.7);
    for j=1:length(pos)
        imwrite(pos{j},fullfile(pos_dir,sprintf('img%.4d.jpg',posIdx)));
        posIdx = posIdx+1;
    end
    for j=1:length(neg)
        imwrite(neg{j},fullfile(neg_dir,sprintf('img%.4d.jpg',negIdx)));
        negIdx = negIdx+1;
    end
end