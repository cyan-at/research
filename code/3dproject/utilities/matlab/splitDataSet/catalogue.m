function [ catalog ] = catalogue(target, t)
%takes a 'target' directory
%gives you all of the files of a certain 'type'
%except any specific filenames you want to reject
%rejects all invisible files
    catalog = {};
    fpath = dir(target);
    for i = 1:length(fpath)
        n = fpath(i).name;
        first_char = n(1);
        if ((~strcmp(first_char,'.')))
            [x, y, z] = fileparts(fpath(i).name);
            if (strcmp(z,strcat('.',t)))
                % it is of the data type you want
                catalog{end+1} = fullfile(target, n);
            end
        end
    end
end

