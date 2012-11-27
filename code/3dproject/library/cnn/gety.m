function y = gety(I,bndbox,fSize)
    % assume I is grey scale
    y = zeros(size(I(:,:,1))-fSize+1);
    y(bndbox(2):bndbox(4)-fSize+1,bndbox(1):bndbox(3)-fSize+1) = 1;
end