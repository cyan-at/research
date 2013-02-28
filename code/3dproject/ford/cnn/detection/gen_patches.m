function feat = gen_patches(vid,ws)
[h,w,d] = size(vid);
feat = zeros(d*ws^2,(h-ws+1)*(w-ws+1));
k = 0;

for j = 1:w-ws+1,
    for i = 1:h-ws+1,
        k = k+1;
        feat(:,k) = vec(vid(i:i+ws-1,j:j+ws-1,:));
    end
end

return;
