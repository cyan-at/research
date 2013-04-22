%Russell Cohen, 2009
%polyLong2PolyShort:
%converts a polygon in the [x y x y x y x .. ] format to the [x y; x y;
%...] format
function pts = polyLong2PolyShort(polyLong)
    x = polyLong(1:2:end)';
    y = polyLong(2:2:end)';
    pts = [x,y];
end