function [parameters] = loadParameters(srcPath, name)
%parameters is a struct created from the parameters.txt file
%cell2struct is really cool!
    if nargin > 1
        n = name;
    else
        n = 'parameters.txt';
    end
    file = fullfile(srcPath, n);
    fid = fopen(file);
    data = textscan(fid, '%s', 'delimiter', ':');
    data = data{1}';
    structSize = length(data)/2;
    fieldArray = cell(1,structSize);
    structCell = cell(structSize,1);
    for i = 1:length(data)
        if (mod(i,2) == 0)
            if (strcmp(data{i},'gray'))
                structCell{i/2} = data{i};
            else
                if isempty(str2num(data{i}))
                    structCell{i/2} = data{i};
                else
                    structCell{i/2} = str2num(data{i});
                end
            end
        else
            fieldArray{(i+1)/2} = strrep(data{i},' ', '_');
        end
    end
    parameters = cell2struct(structCell, fieldArray, 1);
end