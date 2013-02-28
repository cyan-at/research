function mapped = mapResults(bndboxes, param)
%bndbox is of the format: [lowy,lowx,highy,highx];
    mm = param.MappingMatrix;
    xs = bndboxes(:,1);
    ys = bndboxes(:,2);
    [xsf ysf]= distort_pixels(xs ,ys,squeeze(mm),616,1616);
    xs2 = bndboxes(:,3);
    ys2 = bndboxes(:,4);
    [xsf2 ysf2] = distort_pixels(xs2,ys2,squeeze(mm),616,1616);
    mapped = [xsf ysf xsf2 ysf2];
    mapped = mapped + 120.*repmat([1,0,1,0],size(mapped,1),1)-120.*repmat([0,1,0,1],size(mapped,1),1);
end