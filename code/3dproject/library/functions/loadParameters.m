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
    parameters = struct();
    for i = 1:length(data)
        if strcmp(cell2mat(data(i)),'class')
            parameters.class = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'pyramid')
            parameters.pyramid = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'numHidden')
            parameters.numHidden = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'ps')
            parameters.ps = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'gs')
            parameters.gs = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'imgW')
            parameters.imgW = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'minN')
            parameters.minN = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'radius')
            parameters.radius = str2num(cell2mat(data(i+1)));
        end
        if strcmp(cell2mat(data(i)),'mode')
            parameters.mode = cell2mat(data(i+1));
        end
    end
end