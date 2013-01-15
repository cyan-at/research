function [ ppmFile ] = getPpmFile( t )
%GETPPMFILE
[~,y] = strtok(t,'_'); [y,~] = strtok(y,'_'); [y,~] = strtok(y,'/');
ppmFile = strcat(t, sprintf('image_%s.ppm',y));
end

