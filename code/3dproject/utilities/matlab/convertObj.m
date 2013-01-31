current = dir(pwd);
for i = 1:length(current)
    matName = current(i).name;
    if ~strcmp(matName, '.') && ~strcmp(matName, '..') && ~strcmp(matName, 'convertObj.m')
        fprintf('converting %s\n', matName);
        savepath = sprintf('%s/%s',pwd,matName);
        load(savepath);
        obj = nonlap_neg_obj;
        save(savepath,'obj','img');
    end
end
