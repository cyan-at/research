function [alert,mapped] = mapResults2(bndboxes, param)
%bndbox is of the format: [lowy,lowx,highy,highx];
    mm = param.MappingMatrix;
    xs = bndboxes(:,1);
    ys = bndboxes(:,2);
    [xsf ysf]= distort_pixels(xs ,ys,squeeze(mm),616,1616);
    xs2 = bndboxes(:,3);
    ys2 = bndboxes(:,4);
    [xsf2 ysf2] = distort_pixels(xs2,ys2,squeeze(mm),616,1616);
    if size(xsf,1) == size(xsf2,1)
        mapped = [xsf ysf xsf2 ysf2];
        %hack, to remove:
        %mapped = mapped + 120.*repmat([1,0,1,0],size(mapped,1),1)-120.*repmat([0,1,0,1],size(mapped,1),1);
        %flip x's
        mapped = [616+616-mapped(:,1),mapped(:,2),616+616-mapped(:,3),mapped(:,4)];
        mapped = [mapped,bndboxes(:,5:7)];
        alert = 0;
    else
        mapped = [];
        alert = 1;
    end
end