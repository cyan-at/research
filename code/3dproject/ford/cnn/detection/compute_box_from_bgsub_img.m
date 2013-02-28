function boxes = compute_box_from_bgsub_img(im_fgd,boxes1,numperframe)

%%% compute the bounding boxes from the background subtracted images
m = zeros(size(boxes1,1),1);
for i = 1:size(boxes1,1),
    x1 = floor(boxes1(i,1));
    y1 = floor(boxes1(i,2));
    x2 = ceil(boxes1(i,3));
    y2 = ceil(boxes1(i,4));
    m(i) = mean(vec(im_fgd(y1:y2,x1:x2)));
    %     fprintf('%g\n',m(i));
    %     rectangle('Position',[x1 y1 x2-x1 y2-y1],'LineWidth',2,'EdgeColor','r');
end
[m,id] = sort(m,'descend');
lnt = sum(m > 10);
numobj = min(min(size(boxes1,1),numperframe),lnt);
if numobj > 0,
    boxes = boxes1(id(1:numobj),:);
else
    boxes = [];
end

return;

function a = vec(b)
a = b(:);
return;