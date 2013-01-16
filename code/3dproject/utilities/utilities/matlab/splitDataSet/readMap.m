function [ map ] = readMap( idxFile, mapFile )
    %reads the map and creates the directory structure
    indexes = csvread(idxFile);
    fid = fopen(mapFile);
    tline = fgetl(fid);
    lines = {};
    while ischar(tline)
        lines{end+1} = tline;
        tline = fgetl(fid);
    end
    fclose(fid);
    map = {};
    for i = 1:length(indexes)
        map{end+1} = strread(lines{indexes(i)},'%s');
    end
    
    for i = 1:length(map)
        numbers = regexp(map{i}{2},'_','split');
        targetdir =  sprintf('./data/training/raw_data/%s', map{i}{2});%this is the directory to extract zip contents into
        trackletsdir = sprintf('%s/tracklets',targetdir);
        if ~exist(targetdir,'dir')
            mkdir(targetdir);
            mkdir(trackletsdir);
            disp(i);
            %download from KITTI
            %http://www.mrt.kit.edu/geigerweb/cvlibs.net/kitti/raw_data/2011_09_26_drive_0002/2011_09_26_drive_0002.zip
            name = sprintf('%s_%s_%s_%s_%s', cell2mat(numbers(1)),cell2mat(numbers(2)), cell2mat(numbers(3)), cell2mat(numbers(4)), cell2mat(numbers(5)));        
            nameshell = sprintf('./%s.sh', name);
            fileID = fopen(nameshell,'w');
            url = sprintf('http://www.mrt.kit.edu/geigerweb/cvlibs.net/kitti/raw_data/%s/%s.zip',name, name);
            zipname = sprintf('%s.zip',name);
            dwnldmsg = sprintf('downloading %s', zipname);
            unzipmsg = sprintf('unzip %s', zipname);
            dwncmd = sprintf('wget %s -O %s\n', url, zipname);
            unzipcmd = sprintf('unzip %s -d %s\n', zipname, targetdir);
            disp(dwnldmsg); fprintf(fileID,dwncmd); %system(dwncmd); %urlwrite(url, zipname);
            disp(unzipmsg); fprintf(fileID,unzipcmd); %system(unzipcmd); %unzip(zipname,targetdir);
            %download tracklets
            %http://www.mrt.kit.edu/geigerweb/cvlibs.net/kitti/raw_data/2011_09_26_drive_0001/2011_09_26_drive_0001_tracklets.zip
            trackletsname = strcat(name, '_tracklets');
            url = sprintf('http://www.mrt.kit.edu/geigerweb/cvlibs.net/kitti/raw_data/%s/%s.zip',name, trackletsname);
            zipname2 = sprintf('%s.zip', trackletsname);
            dwnldmsg = sprintf('downloading %s', zipname2);
            unzipmsg = sprintf('unzip %s', zipname2);
            dwncmd = sprintf('wget %s -O %s\n', url, zipname2);
            unzipcmd = sprintf('unzip %s -d %s\n', zipname2, trackletsdir);
            disp(dwnldmsg); fprintf(fileID,dwncmd); %system(dwncmd); %urlwrite(url, zipname2);
            disp(unzipmsg); fprintf(fileID,unzipcmd); %system(unzipcmd); %unzip(zipname2, trackletsdir);
            disp('cleaning up');
            deletecmd = sprintf('rm %s %s\n', zipname, zipname2);
            fprintf(fileID,deletecmd); % system(deletecmd);
            fclose(fileID);
            chmodcmd = sprintf('chmod +x %s', nameshell);
            runcmd = sprintf('%s &', nameshell);
            system(chmodcmd);
            system(runcmd);
        end
    end
end

