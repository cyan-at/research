function A = estimateA(uvs,xyzs)
%uvs is n x 3
%xyzs is n x 2
maxIterations = 500;

A = rand(3,2);
for i = 1:maxIterations
    idx = randi(size(uvs,1),3,1);
    a = xyzs(idx,:);
    b = uvs(idx,:);
    x = pinv(a)*b;
    n = norm(a*x-b);
    disp(n);
    diff = A-x;
    A = x;
    disp(norm(diff));
end
A = [];
end