function gt = bndbox_to_gt(bndbox)
min_size = [44 79]*1.2^(-2);
max_size = [44 79]*1.2^(3);
gt.BB = bndbox;
gt.diff = zeros(size(bndbox,1),1);
gt.det = zeros(size(bndbox,1),1);
for i=1:size(bndbox,1)
    cur_box = bndbox(i,:);
    width = cur_box(3)-cur_box(1);
    height = cur_box(4)-cur_box(2);
%     if width < min_size(1) & height < min_size(2)
% %             width > max_size(1) & height > max_size(2)
%         gt.diff(i) = 1;
%     end
%     if width < min_size(1) || width > max_size(1) ...
%             || height > min_size(2) || height > max_size(2)
%         gt.diff(i) = 1;
%     end
end