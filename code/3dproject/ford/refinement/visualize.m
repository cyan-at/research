function visualize(img, varargin)
%varargin is the number of matrices, where each matrix is a list of
%bounding boxes to be plotted with their own color
cmap = 'ymcrgbwk';
final = [];
finalcolor = '';
for i = 1:nargin-1
    final = [final;cell2mat(varargin(i))];
    j = mod(i,nargin-1)+1;
    finalcolor = strcat(finalcolor,repmat(cmap(j),1,size(cell2mat(varargin(i)),1)));
end
finalCell = num2cell(final,2);
%show bounding boxes and colors
showboxes_color(img,finalCell,finalcolor);
end

