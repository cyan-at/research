function drawResults(scanfolder, bndboxes, varargin)
%DRAWRESULTS draws classified results onto 2D space

%show the full image
imageName = strcat(scanfolder,'/imageFull.ppm');
I = imread(imageName);
height = size(I,1)/5;
width = size(I,2);
if(height == 616)
    height = height*2;
    I = imresize(I, [height*5 width]);
end
I_rotated = imrotate(I, -90);
I_rotated = flipdim(I_rotated,2);
figure, imshow(I_rotated);
col = size(I,2) - 1;
row = size(I,1)/5 - 1;

%load parameters
paramFile = '/mnt/neocortex/scratch/jumpbot/data/3dproject/Ford/PARAM.mat'; load(paramFile);

%construct bboxes cell array
bboxes = [];
for camindex = 0:4
    %load parameters
    K = PARAM(camindex+1).K;
    R = PARAM(camindex+1).R;
    t = PARAM(camindex+1).t;
    MappingMatrix = PARAM(camindex+1).MappingMatrix;
    
    %compute some offset
    if(camindex < 3)
        camoffset = 2 - camindex;
    else
        camoffset = 7 - camindex;
    end
    yoffset = height*camoffset;

    %get all the coordinates on that camera
    cambndboxes = find(bndboxes(:,5)==(camindex+1));
    if (isempty(cambndboxes)); continue; end;
    coordinates = bndboxes(cambndboxes,1:4);
    
    %distort pixels
    [lowx lowy validslow]= distort_pixels(coordinates(:,2) ,coordinates(:,1),squeeze(MappingMatrix),row+1,col+1);
    [highx highy validshigh]= distort_pixels(coordinates(:,4) ,coordinates(:,3),squeeze(MappingMatrix),row+1,col+1);
    valids = intersect(validslow, validshigh);
    %map back to original matrix
    [lowx lowy v2l]= distort_pixels(coordinates(valids,2) ,coordinates(valids,1),squeeze(MappingMatrix),row+1,col+1);
    [highx highy v2h]= distort_pixels(coordinates(valids,4) ,coordinates(valids,3),squeeze(MappingMatrix),row+1,col+1);
    v = intersect(v2l, v2h);
    coordinates = [lowy(v), lowx(v), highy(v), highx(v)];
    if (~isempty(coordinates))
        coordinates = repmat((yoffset)*[1 0 1 0],size(coordinates,1),1) + repmat([1 1 1 1],size(coordinates,1),1) .* coordinates;
        bboxes = [bboxes; coordinates];
    end
end

bboxes = num2cell(bboxes,2);
%finally show bboxes
showboxes_color(I_rotated, bboxes, 'b');

%save to file
if (nargin > 2)
    disp('saving figure');
    print(gcf, '-dpng', cell2mat(varargin(1)), '-r300');
end
end

