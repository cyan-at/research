function removeSegments( directory )
    % cleans up the pcd files found in 'directory'
    disp(directory);
    d = dir(directory);
    for i = 1:length(d)
        if (strcmp(d(i).name, '..') || strcmp(d(i).name, '.'))
        else
            dname = d(i).name;
            if (strcmp(dname(1:3),'pcd') == 0) % 'the rule'      
                %prepare rm statement
                %disp(dname);
                rmCmd = sprintf('rm %s', fullfile(directory,dname));
                system(rmCmd);
                %disp(rmCmd);
            else
                %disp(dname);
            end
        end
    end
end

