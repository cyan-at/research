function ensure( path )
%ENSURE Summary of this function goes here
%   Detailed explanation goes here
if (~exist(path,'dir')); mkdir(path); end;
end

