function [ pc ] = pcd2mat( pcdfile )
%Takes a pcd, and returns a mat
%3 x n
pc = [];
fid = fopen(pcdfile);
tline = fgetl(fid);
line = 0;
points = 0;
pointIndex = 1;
while ischar(tline)
    line = line + 1;
    %disp(line);
    if (strcmp(tline(1:6),'POINTS'))
        parts = strread(tline,'%s','delimiter',' ');
        c = str2double(cell2mat(parts(2)));
        pc = zeros(c,11);
    end
    if (line > 11)
        points = points + 1;
        parts = strread(tline,'%s','delimiter',' ');
        point=cellfun(@str2double,parts)';
        pc(pointIndex,:) = point;
        pointIndex = pointIndex + 1;
    end
    tline = fgetl(fid);
end
fclose(fid);

end

