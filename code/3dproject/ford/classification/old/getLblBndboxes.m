function all = getLblBndboxes(objPath)
    %this function takes every bounding box and maps it back to 3D space
    %specifically, finds all the labels in the directory
    camObjs = catalogue(objPath,'mat','cam');
    all = [];
    for i = 1:length(camObjs)
        matfile = cell2mat(camObjs(i));
        [~,y,~] = fileparts(matfile);
        x = strsplit(y,'cam');
        x = str2num(cell2mat(x(2)));
        %img = imread(strcat(objPath,'/cam',x,'.png'));
        load(matfile);
        for j = 1:length(obj)
            %all = [all;[obj(j).bndbox(1), obj(j).bndbox(2), obj(j).bndbox(3), obj(j).bndbox(4)]];
            all = [all;[obj(j).bndbox(1), obj(j).bndbox(2), obj(j).bndbox(3), obj(j).bndbox(4), x]];
        end
        %all2 = num2cell(all,2);
        %showboxes_color(img,all2,'b');
    end
end