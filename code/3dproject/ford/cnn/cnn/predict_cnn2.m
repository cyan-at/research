function pred_bbox = predict_cnn2(IMAGES,filter_size,num_images,model,optConv, resize_times, resize_array)
% simple prediction
% optConv: 'J' = use jacket, 'I' = use conv2_ipp otherwise use default conv2

if length(IMAGES) < num_images
    error('inconsitent number of images');
end

if ~exist('resize_times','var') || resize_times == 1
    pred_bbox = predict_cnn(IMAGES,filter_size,num_images,model,optConv);
    return;
end

c = cell(num_images,1);
pred_bbox{1} = [];
% size_w = size(model.W);
for j=1:num_images
    I0 = double(IMAGES{j});
    for k = 1 : resize_times
        %I = IMAGES{j};
        I = imresize(I0, resize_array(k));
        
        P = 0;
    %     corr = 1
        % compute the activation, P
        for i=1:size(model.W,3)
            if optConv == 'J'
                P = P+double(conv2(gdouble(I(:,:,i)),gdouble(rot90(model.W(:,:,i),2)),'valid')+model.b);
            elseif optConv == 'I'
                addpath /afs/umich.edu/user/h/o/honglak/Library/convolution/IPP-conv2-mex/
                P = P+conv2_ipp(I(:,:,i),rot90(model.W(:,:,i),2),'valid')+model.b;
            else
                P = P+(conv2(I(:,:,i),rot90(model.W(:,:,i),2),'valid')+model.b);
            end
        end

        % find the location where the activation > 0 and draw bbox
        [r c] = find(P>-1);
        try
            %pred_bbox{j} = [c r c+filter_size(2)-1 r+filter_size(1)-1 zeros(length(r),1)];
            new_bbox{j} = [c r c+filter_size(2)-1 r+filter_size(1)-1 zeros(length(r),1)]/resize_array(k);
        catch
            %pred_bbox{j} = [c' r' c'+filter_size(2)-1 r'+filter_size(1)-1 zeros(length(r'),1)];
            new_bbox{j} = [c' r' c'+filter_size(2)-1 r'+filter_size(1)-1 zeros(length(r'),1)]/resize_array(k);
        end
        for i=1:length(r)
            new_bbox{j}(i, 5) = P(r(i),c(i));
            %pred_bbox{j}(i,5) = P(r(i),c(i));
        end
%         idx=nms(pred_bbox{j},.5);  % apply nms
%         pred_bbox{j} = pred_bbox{j}(idx,:);

        idx=nms(new_bbox{j},.5);  % apply nms
        new_bbox{j} = new_bbox{j}(idx,:);

        if size(pred_bbox) < j
            pred_bbox{j} = [];
        end
        pred_bbox{j} = [pred_bbox{j}; new_bbox{j}];
        
        clear P;
    end
    idx=nms(pred_bbox{j},.5);  % apply nms
    pred_bbox{j} = pred_bbox{j}(idx,:);
    
end
function y = vec(x)
y = x(:);