function [accm, accv, cls, acc_max, acc_vote, species_list] = do_voting(pred,database)
numvid = length(database.cname);
nlabel = max(database.label);
acc_max = zeros(numvid,1);
acc_vote = zeros(numvid,1);
cls = zeros(numvid,1);
species_list = zeros(numvid,nlabel);
for i = 1:numvid,
    idx = database.cind(i,1):database.cind(i,2);
    if ~isempty(idx),
        p = zeros(nlabel,1);
        for j = 1:nlabel,
%             try
            p(j) = sum(pred(idx) == j)/length(idx);
%             catch                
%             end
        end
        [~,id] = max(p);
        cls(i) = id;
        if id == unique(database.label(idx)),
            acc_max(i) = 1;
        end
        acc_vote(i) = p(unique(database.label(idx)));
        
        for j=1:nlabel
            species_list(i,j) = length(find(pred(idx) == j));
        end
    end
end
accm = mean(acc_max);
accv = mean(acc_vote);

return;

