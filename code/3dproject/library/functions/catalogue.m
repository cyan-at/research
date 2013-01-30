function [ catalog ] = catalogue( path, extension )
%takes a directory, and the parameters about that directory of features,
%and creates a 'catalogue' array of paths
    catalog = {};
    fpath = dir(path);
    for i = 1:length(fpath)
        matName = fpath(i).name;
        first_char = matName(1);
        [~,~,ext] = fileparts(matName);
        if (strcmp(strcat('.',extension),ext) && (~strcmp(first_char,'.')))
            catalog{end+1} = fullfile(path, matName);
        end
    end
end

