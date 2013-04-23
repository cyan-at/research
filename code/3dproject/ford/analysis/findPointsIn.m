function [inside] = findPointsIn(a, points)
%standardize coordinates
%points u,v u = points(:,1), v = points(:,2)
%a is lowu, lowv, highu, highv
%a point is in range if it's lowu <= u <= highu
inside = find(points(:,1) <= a(3) & points(:,1) >= a(1) & points(:,2) <= a(4) & points(:,2) >= a(2));
end