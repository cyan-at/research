%change name to kernel_detector afterwards
function result = sift_detector(frame, ref_size, ps, gs, km, sp, svm, objperimg, type)
    [gridX,gridY] = meshgrid(floor(ps/2)+1:gs:size(frame,2)-floor(ps/2)-1, floor(ps/2)+1:gs:size(frame,1)-floor(ps/2)-1);
    if strcmp(type,'sift')
        feaArr = sp_find_sift_grid(im2double(rgb2gray(frame)), gridX, gridY, ps, 0.8); %0.8?    %currently slow, but see whether it works first
        feaArr = single(sp_normalize(feaArr,1,0.2))';         
    elseif strcmp(type , 'color')
        feaArr = find_color_hist_grid(frame, gridX, gridY, ps)';
    end
    acti = km.fprop(feaArr);

    %divide to patches as ref size
    gridX = gridX(:);
    gridY = gridY(:);
    heat_map_pos = zeros(size(frame,1)-ref_size(1) + 1, size(frame,2)-ref_size(2)+1);
    heat_map_neg = zeros(size(heat_map_pos));

    step = 3;
    for i = 1 :step: size(frame,1)-ref_size(1) + 1
        fprintf('[%d/%d]',i,size(frame,1)-ref_size(1) + 1);
        for j = 1 :step: size(frame,2)-ref_size(2)+1
            num_x = unique(gridX(gridX >= j & gridX <= j+ref_size(2)-1));
            num_y = unique(gridY(gridY >= i & gridY <= i+ref_size(1)-1));
            idx = (gridX >= j & gridX <= j+ref_size(2)-1 & gridY >= i & gridY <= i+ref_size(1)-1);
            curr_fea = sp.fprop(reshape(acti(:,idx)',[length(num_y), length(num_x), km.numunits]));         
            %how to translate svm's result into probability?
            heat_map_pos(i,j) = svm.model.weights(:,1)'*curr_fea;
            heat_map_neg(i,j) = svm.model.weights(:,2)'*curr_fea;
        end
    end

    %get bounding box from heat_map

    heat_map = heat_map_pos - heat_map_neg;
    vec= @(x) x(:);
    % res = heat_map > 0;
    [~, idx] = sort(heat_map(:), 'descend');

    boxes = zeros(length(idx),5);
    boxes(:,1) = floor((idx-1) / size(heat_map,1))+1;
    boxes(:,2) = mod(idx-1, size(heat_map,1))+1;
    boxes(:,3) = boxes(:,1) + ref_size(2)-1;
    boxes(:,4) = boxes(:,2) + ref_size(1)-1;
    boxes(:,5) = vec(heat_map_pos(idx) - heat_map_neg(idx));
    pick = nms(boxes, 0.5);
    pick = pick(1:objperimg);
    result = boxes(pick,1:4);
end