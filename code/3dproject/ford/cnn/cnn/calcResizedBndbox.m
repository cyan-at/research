function [ new_bndbox ] = calcResizedBndbox( init_h, init_w, init_bndbox, ...
            new_h, new_w,ps)
% init_h is the initial number of rows.
% init_w is the initial number of columns.
% inti_bndbox is the initial bounding box, in the format of [h1, w1, h2,
% w2] where (h1, w1) is the coordinates of the upper-left point of the
% bounding box, and (h2, w2) is the coordinates of the bottom-right point.

% new_bndbox is in format of [h1, w1, h2, w2], where (h1, w1) is the 
% coordinates of the upper-left point of the new bounding box, and (h2, w2)
% is the coordinates of the bottom-right point.
        
        h_ratio = new_h / init_h;
        w_ratio = new_w / init_w;
        
        new_bndbox = [(init_bndbox(1)+2*ps) * h_ratio, ...
                      (init_bndbox(2)+2*ps) * w_ratio, ...
                      (init_bndbox(3)+2*ps) * h_ratio, ...
                      (init_bndbox(4)+2*ps) * w_ratio];
                  
        new_bndbox = round(new_bndbox);
      
end

