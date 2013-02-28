function [ result ] = boxIn( a, b )
%returns the bounding box that is inside the other, otherwise []
%assume that a, and b are 1 x 4 + other info where the first 4 columns are
%data
result = [];
a2 = [min(a(:,1),a(:,3)),min(a(:,2),a(:,4)),max(a(:,1),a(:,3)),max(a(:,2),a(:,4))];
b2 = [min(b(:,1),b(:,3)),min(b(:,2),b(:,4)),max(b(:,1),b(:,3)),max(b(:,2),b(:,4))];

%checks
relax = 0;
if (a2(1) <= b2(1) && a2(3) >= b2(3) && a2(2) <= b2(2) && a2(4) >= b2(4))
    %b is inside of a
    result = b;
    %add up scores
    result(6) = a(6) + b(6);
    %result(6) = max(a(6),b(6));
end

if (a2(1) >= b2(1) && a2(3) <= b2(3) && a2(2) >= b2(2) && a2(4) <= b2(4))
    %a is inside of b
    result = a;
    %add up scores
    %result(6) = a(6) + b(6);
    result(6) = max(a(6),b(6));
end

end

