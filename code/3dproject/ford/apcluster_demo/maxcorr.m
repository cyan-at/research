function dist = maxcorr(A,B, ws)

wa = reshape(A,ws,ws);
wb = reshape(B,ws,ws);

C=xcorr2(wa,wb);

[mval mrow] = max(C,[],1);
[~, mcol] = max(mval);

col = mcol; % x value
row = mrow(mcol); % y value


dist = C(row, col)/(norm(A(:))*norm(B(:)));

return
