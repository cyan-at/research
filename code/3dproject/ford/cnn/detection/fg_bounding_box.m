function [IM, est] = fg_bounding_box(data, mask, thre, enlarge1, enlarge2, show)
%only support color data now
    h = size(data,1);
    w = size(data,2);
    IM = {};
    est = {};
    for i = 1 : size(mask,3)
        [image1 num] = bwlabel(mask(:,:,i));
        stats = regionprops(image1, 'BoundingBox');
        tmp = mask(:,:,i);
        for j = 1 : length(stats)
            if stats(j).BoundingBox(3) > thre && stats(j).BoundingBox(4) > thre
                stats(j).BoundingBox(1) = floor(max(1, stats(j).BoundingBox(1)-enlarge1));
                stats(j).BoundingBox(2) = floor(max(1, stats(j).BoundingBox(2)-enlarge1));
                stats(j).BoundingBox(3) = floor(min(w, stats(j).BoundingBox(3)+ enlarge1*2));
                stats(j).BoundingBox(4) = floor(min(h, stats(j).BoundingBox(4)+ enlarge1*2));
                for k = stats(j).BoundingBox(2):stats(j).BoundingBox(2)+stats(j).BoundingBox(4)
                    tmp(k,stats(j).BoundingBox(1):stats(j).BoundingBox(1)+stats(j).BoundingBox(3)) = 1;
                end
            end
        end        
        [image1 num] = bwlabel(tmp);
        stats = regionprops(image1, 'BoundingBox');
        
        if show
            imagesc(data(:,:,:,i)/255);
        end
        est_curr = zeros(4, length(stats));
        cnt = 1;
        for j = 1 : length(stats)
            if stats(j).BoundingBox(3) > thre && stats(j).BoundingBox(4) > thre
                stats(j).BoundingBox(1) = max(1, stats(j).BoundingBox(1)-enlarge2);
                stats(j).BoundingBox(2) = max(1, stats(j).BoundingBox(2)-enlarge2);
                stats(j).BoundingBox(3) = min(w, stats(j).BoundingBox(3)+ 2*enlarge2);
                stats(j).BoundingBox(4) = min(h, stats(j).BoundingBox(4)+ 2*enlarge2);
                boxes = [stats(j).BoundingBox(1), stats(j).BoundingBox(1)+stats(j).BoundingBox(3); stats(j).BoundingBox(2), stats(j).BoundingBox(2)+stats(j).BoundingBox(4)];
                corners = [boxes(:,1), [boxes(1,1); boxes(2,2)], boxes(:,2),  [boxes(1,2); boxes(2,1)], boxes(:,1)];
                if show
                    line(corners(1,:), corners(2,:),'Color','r', 'LineWidth',2.5);
                end
                est_curr(:,cnt) = stats(j).BoundingBox;
                cnt = cnt + 1;
            end
        end
        est_curr(:,cnt:end) = [];
        est{length(est)+1} = est_curr;
        if show
            pause(0.1);
        end
    end

    for i = 1 : length(est)
        box_curr = est{i};
        for j = 1 : size(box_curr,2)
            boxes = box_curr(:,j);                        
            IM{length(IM)+1} = data(max(1,boxes(2)):min(boxes(2)+boxes(4),h), max(1,boxes(1)):min(w,boxes(1)+boxes(3)),:,i);
        end
    end
    
end