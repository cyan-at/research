function bndbox = getBndbox(pc)
%pc is now a n x 11 matrix [x y z rgb r g b pixelx pixely cam ith]
%get all of the pixelx, pixely
uvs = pc(:,8:9);
%find top left corner
%find bottom right corner
bndbox = [];
end