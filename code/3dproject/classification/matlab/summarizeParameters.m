function [summary] = summarizeParameters(parameters)
%This function takes a struct 'parameters'
%returns a string concatenated with \n
values = struct2cell(parameters);
fields = fieldnames(parameters);
summary = '';
for i = 1:length(fields)
   cell2mat(fields(i));
end
end