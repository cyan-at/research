function label = findLabel( bndBox, obj, threshold )
%FINDLABEL
label = 'not';
obj = obj.obj;
bndBox(3) = bndBox(1) + bndBox(3);
bndBox(4) = bndBox(2) + bndBox(4);
%disp(bndBox);
for i = 1:length(obj)
    if boxoverlap(obj(i).bndbox, bndBox) > threshold;
        label = obj.class;
        return;
    end
end
end

