function [parameters] = loadResults(srcPath, name)
%parameters is a struct created from the parameters.txt file
%cell2struct is really cool!
    if nargin > 1
        n = name;
    else
        n = 'results.txt';
    end
    parameters = struct;
    file = fullfile(srcPath, n);
    fid = fopen(file);
    tline = fgets(fid);
    while ischar(tline)
        tline = fgets(fid);
        k = strfind(tline, 'average precision ');
        if ~isempty(k)
           %disp(tline); 
           x = regexp(tline, ' = ', 'split');
           parameters.ap = cell2mat(x(2));
        end
    end
    fclose(fid);
end