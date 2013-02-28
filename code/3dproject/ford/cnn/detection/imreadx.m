function im = imreadx(ex)

% Read a training example image.
%
% ex  an example returned by pascal_data.m

im = color(imread(ex.im));
% if ex.rot ~= 0
%    im = imrotate(im,ex.flip*90 );
% end
% im = rotate_img(im,[ex.x1 ex.y1 ex.x2 ex.y2], ex.flip*90);
if ex.flip
   im = im(:,end:-1:1,:);
end
