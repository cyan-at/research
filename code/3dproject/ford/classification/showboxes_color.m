function showboxes_color(im, cell_boxes, colors)

% showboxes(im, boxes, out)
% Draw bounding boxes on top of image.
% If out is given, a pdf of the image is generated (requires export_fig).

image(im);
axis image;
axis off;
set(gcf, 'Color', 'white');
for k=1:length(cell_boxes)
    boxes = cell_boxes{k};
    if ~isempty(boxes)
        numfilters = floor(size(boxes, 2)/4);
        % draw the boxes with the detection window on top (reverse order)
        for i = numfilters:-1:1
            x1 = boxes(:,1+(i-1)*4);
            y1 = boxes(:,2+(i-1)*4);
            x2 = boxes(:,3+(i-1)*4);
            y2 = boxes(:,4+(i-1)*4);
            % remove unused filters
            del = find(((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0)) == 1);
            x1(del) = [];
            x2(del) = [];
            y1(del) = [];
            y2(del) = [];
%             if i == 1
%                 c = [160/255 0 0];
%                 s = '-';
%             else
%                 c = 'b';
%                 s = '-';
%             end
            c = mod(k,length(colors));
            if c == 0
                c = length(colors);
            end
            line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', colors(c), 'linewidth', 2, 'linestyle', '-');
        end
    end
end
