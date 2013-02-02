function [ catalog ] = catalogue(path, extension, varargin)
%takes a directory, and the parameters about that directory of features,
%and creates a 'catalogue' array of paths
if (nargin == 3)
    x = varargin{1};
else
    x = '';
end
if (~strcmp(extension,'folder'))
catalog = {};
fpath = dir(path);
for i = 1:length(fpath)
    matName = fpath(i).name;
    first_char = matName(1);
    if (length(matName) >= length(x))
        firstN = matName(1:length(x));
    else
        firstN = '';
    end
    [~,~,ext] = fileparts(matName);
    if (strcmp(x,''))
        if (strcmp(strcat('.',extension),ext) && ~strcmp(first_char,'.'))
            catalog{end+1} = fullfile(path, matName);
        end
    else
        if (strcmp(strcat('.',extension),ext) && ~strcmp(first_char,'.') && strcmp(firstN,x))
            catalog{end+1} = fullfile(path, matName);
        end
    end
end
else
d = dir(path);
isub = [d(:).isdir];
catalog = {d(isub).name}';
catalog(ismember(catalog,{'.','..'})) = [];
end
end

