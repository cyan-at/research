function [rec, prec, ap] = compute_avgpc(label,score)
rec = zeros(size(label));
prec = zeros(size(label));
s = sort(score, 'ascend');
for i=1:length(label)
    [rec(i) prec(i)] = compute_rcpc(label,score,s(i)); 
end
ap=0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end

function [recall precision] = compute_rcpc(label,score,thresh)
fprintf('thresh is %g\n',thresh);
pred = 2*ones(size(score));
pred(score>=thresh) = 1;
not_idx = find(label == 1);
idx = find(label == 2);
recall = sum(label(idx) == pred(idx))/length(idx);
precision = sum(label(idx) == pred(idx))/(sum(label(idx) == pred(idx))+sum(label(not_idx) ~= pred(not_idx)));