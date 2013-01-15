function [ pngTarget ] = getPngTarget( t )
%GETPNGTARGET
[~,y] = strtok(t,'_'); [y,~] = strtok(y,'_'); [y,~] = strtok(y,'/');
pngTarget = strcat(t, sprintf('image_%s.png',y));
end
