%in each of these directories, apply the felzen segmentation
loadPaths;
clickPrefix = '/home/charlie/Desktop/research/code/toyotascene/2dTo3d/c/build/clickPCD';
for i = 1:length(traindir)
	t = cell2mat(traindir(i));
    %construct the pcd file
    scanFile = getScanFile(t);
    [x, y, z] = fileparts(scanFile);
    pcdFile = strcat(x,'/',y,'.pcd');
    %construct the point file to write points to
    pointFile = strcat(x,'/',y,'_points.txt');
    pixelFile = strcat(x,'/',y,'_pixels.txt');
    if (~exist(pointFile,'file'))
        system(sprintf('touch %s',pointFile));
    else
        system(sprintf('rm %s',pointFile));
        system(sprintf('touch %s',pointFile));
    end
    
    if (~exist(pixelFile,'file'))
        system(sprintf('touch %s',pixelFile));
    else
        system(sprintf('rm %s',pixelFile));
        system(sprintf('touch %s',pixelFile));
    end
    %show something
    ppmFile = getPpmFile(t);
    im = imread(ppmFile);
    h = imshow(im);
    a = input('use this scene (y/n)? ','s');
    if strcmpi(a,'y')
        %capture clicks on image, write these clicks to file
        fid  = fopen(pixelFile,'w');
        while 1,
            [x,y] = ginput(1);
            disp(x(1));
            disp(y(1));
            accept = input('Good with this point (y/n)? ', 's');
            if strcmpi(accept,'y')
                fprintf(fid,'%s, %s\n', x(1), y(1));                
            end
            d = input('Are you done with this image (y/n)? ','s');
            if strcmpi(d,'y')
                break;
            end
        end
        fclose(fid);
    else
        close all;
    end
end