function neg = random_neg(IMAGES,gt,nnpi,filter_size)
% nnpi = num neg per image

addpath ../detection/

neg = zeros(nnpi*length(IMAGES),filter_size(1)*filter_size(2));
for i=1:length(IMAGES)
   [im_h, im_w, ~] = size(IMAGES{i});
   for j=1:nnpi
       while 1
           rx = randi(im_w-filter_size(2),1,1);
           ry = randi(im_h-filter_size(1),1,1);
           bbox = [ry rx ry+filter_size(1)-1 rx+filter_size(2)-1];
           ov = boxoverlap(gt(i),bbox);
           if max(ov) < .5
               neg(nnpi*(i-1)+j,:) = vec(IMAGES{i}(bbox(1):bbox(3),bbox(2):bbox(4),:));
               break;
           end
       end
   end
end