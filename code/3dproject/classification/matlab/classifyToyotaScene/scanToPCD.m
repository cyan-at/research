function scanToPCD( txtfile, outputfile )
%reads a scan file and produces the pcd file for this point cloud
%3 x n
fid = fopen(txtfile);
fid2 = fopen(outputfile,'w');
fprintf(fid2, '# .PCD v0.7 - Point Cloud Data file format\nVERSION 0.7\nFIELDS x y z\n');
fprintf(fid2,'SIZE 4 4 4\n');
fprintf(fid2,'TYPE F F F\n');
fprintf(fid2,'COUNT 1 1 1\n');
tline = fgetl(fid);
line = 0;
while ischar(tline)
    line = line + 1;
    if (line == 1)
        x = str2num(tline);
        pointCountStr = sprintf('POINTS %s\n', num2str(x));
        fprintf(fid2, pointCountStr);
        fprintf(fid2,'VIEWPOINT 0 0 0 1 0 0 0\n');
        fprintf(fid2,'DATA ascii\n');
    else
        %disp(tline);
        parts = strread(tline,'%s','delimiter',' ');
        x = str2num(cell2mat(parts(1)));
        y = str2num(cell2mat(parts(2)));
        z = str2num(cell2mat(parts(3)));
        l = str2num(cell2mat(parts(4)));
        point = [x; y; z];
        %disp(num2str(point'));
        fprintf(fid2,sprintf('%s\n',num2str(point')));
    end
    tline = fgetl(fid);
end
fclose(fid);
fclose(fid2);
end

