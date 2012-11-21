function mergePCDs( directory, prefix, name)
    %MERGE_CLASSIFIED merges all pcds in a 'directory' of the same 'prefix'
    %prefix exampls: not_, car_
    %name is what you want to name the merged file
    mergePrefix = '/home/charlie/Desktop/research/code/utilities/c/mergePCD/test/mergeAll';
    targetPCDs = fullfile(directory,prefix);
    targetPCDs = strcat(targetPCDs, '*.pcd');
    targetNames = dir(targetPCDs);
    arguments = '';
    for i = 1:length(targetNames)
        z = fullfile(directory,targetNames(i).name);
        arguments = sprintf('%s %s', arguments, z);
    end
    targetpcdLoc = fullfile(directory, name);
    arguments = sprintf('%s -o %s', arguments, targetpcdLoc);
    mergeCmd = sprintf('%s %s', mergePrefix, arguments);
    system(mergeCmd);
end

