function y = hascar(objects)
    y = false;
    for i = 1:length(objects)
        if strcmp(objects(i).type,'Car');
            y = true;
        end
    end
end