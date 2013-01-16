function [newpath] = constructscanpath(ppmi)
%given the .ppm path, gets the scan .txt path
[x y z] = fileparts(ppmi);
[a b] = strtok(y,'_');
y2 = sprintf('scan%s.txt',b);
newpath = sprintf('%s/%s',x,y2);
end