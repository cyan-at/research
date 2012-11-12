function [ pc ] = pcd2mat( pcdfile )
%Takes a pcd, and returns a mat
%3 x n
pc = [];
fid = fopen(pcdfile);
tline = fgetl(fid);
line = 0;
points = 0;
while ischar(tline)
    line = line + 1;
    if (line > 11)
        points = points + 1;
        %disp(tline);
        parts = strread(tline,'%s','delimiter',' ');
        x = str2num(cell2mat(parts(1)));
        y = str2num(cell2mat(parts(2)));
        z = str2num(cell2mat(parts(3)));
        point = [x; y; z];
        pc = [pc,point];
    end
    tline = fgetl(fid);
end
fclose(fid);

end

