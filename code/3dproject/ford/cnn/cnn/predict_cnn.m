function pred_bbox = predict_cnn(IMAGES,filter_size,num_images,model,optConv)
% simple prediction
% optConv: 'J' = use jacket, 'I' = use conv2_ipp otherwise use default conv2

if length(IMAGES) < num_images
    error('inconsitent number of images');
end

pred_bbox = cell(num_images,1);
% size_w = size(model.W);
for j=1:num_images
    I = IMAGES{j};
    P = 0;
%     corr = 1;
    % compute the activation, P
    for i=1:size(model.W,3)
%         sum_w = sum(vec(model.W(:,:,i)));
        if optConv == 'J'
            gI = gdouble(I(:,:,i));
            corr = norm(vec(model.W(:,:,i)))*sqrt( conv2( conv2(gI.^2,gdouble(ones(size(model.W(:,:,i),1),1)),'valid'),...
                    gdouble(ones(1,size(model.W(:,:,i),2))), 'valid') )+1e-7;
%             mean_I = double(conv2( conv2(gI,gdouble(ones(size_w(1),1)),'valid'), ...
%                 gdouble(ones(1,size_w(2))),'valid')/(size_w(1)*size_w(2)));
            P = P+double(conv2(gdouble(I(:,:,i)),gdouble(rot90(model.W(:,:,i),2)),'valid')+model.b);%...
%                 -sum_w*mean_I;
        elseif optConv == 'I'
            addpath /afs/umich.edu/user/h/o/honglak/Library/convolution/IPP-conv2-mex/
            P = P+conv2_ipp(I(:,:,i),rot90(model.W(:,:,i),2),'valid')+model.b;
        else
            corr = norm(vec(model.W(:,:,i)))*sqrt( conv2( conv2(I(:,:,i).^2,ones(size(model.W(:,:,i),1),1),'valid'),...
                    ones(1,size(model.W(:,:,i),2)), 'valid') )+1e-7;
            P = P+(conv2(I(:,:,i),rot90(model.W(:,:,i),2),'valid')+model.b);
        end
    end
    
    % find the location where the activation > 0 and draw bbox
    [r c] = find(P>-1);
    try
        pred_bbox{j} = [c r c+filter_size(2)-1 r+filter_size(1)-1 zeros(length(r),1)];
    catch
        pred_bbox{j} = [c' r' c'+filter_size(2)-1 r'+filter_size(1)-1 zeros(length(r'),1)];
    end
    for i=1:length(r)
        pred_bbox{j}(i,5) = P(r(i),c(i));
    end
    idx=nms(pred_bbox{j},.5);  % apply nms
    pred_bbox{j} = pred_bbox{j}(idx,:);

    clear P;
end
function y = vec(x)
y = x(:);