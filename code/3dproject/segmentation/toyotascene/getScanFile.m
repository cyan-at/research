function [ scanFile ] = getScanFile( t )
%GETSCANFILE
[~,y] = strtok(t,'_'); [y,~] = strtok(y,'_'); [y,~] = strtok(y,'/');
scanFile = strcat(t,sprintf('scan_%s.txt',y));
end

