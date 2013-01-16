function im = visualizeHOGnew(w, gridX, gridY, ps)

% visualizeHOG(w)
% Visualize HOG features/weights.

% make pictures of positive and negative weights
bs = ps;
w = w(:,:,1:9);
scale = max(max(w(:)),max(-w(:)));
pos = HOGpicture(w, bs) * 255/scale;
neg = HOGpicture(-w, bs) * 255/scale;

% put pictures together and draw
pos(round(unique(gridX)),:,:) = 255;
pos(:,round(unique(gridY)),:) = 255;

neg(round(unique(gridX)),:,:) = 255;
neg(:,round(unique(gridY)),:) = 255;

buff = ps/2;
pos = padarray(pos, [buff buff], 128, 'both');
if min(w(:)) < 0
  neg = padarray(neg, [buff buff], 128, 'both');
  im = uint8([pos; neg]);
else
  im = uint8(pos);
end

