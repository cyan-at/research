function [ labelMat ] = getLabelMat( t, labelLoc )
%GETSCANFILE
[~,y] = strtok(t,'_'); [y,~] = strtok(y,'_'); [y,~] = strtok(y,'/');
labelMat = strcat(labelLoc,sprintf('image_%s.mat',y));
end
