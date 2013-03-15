function [groups, nesting, scores] = checkNestingv2(cnns)
    groups = [];
    partofgroup = zeros(size(cnns,1),1);
    nesting = zeros(size(cnns,1),1);
    scores = zeros(size(cnns,1),1);
    for bx1 = 1:size(cnns,1)
        %this one's groups
        %disp(num2str(cnns(bx1,:)));
        if (partofgroup(bx1) == 1); continue; end;
        this = []; q = 0; score = 0;
        for bx2 = 1:size(cnns,1)
            if (partofgroup(bx2) == 1); continue; end;
            if (bx1 ~= bx2)
                [temp, idx] = boxIn(cnns(bx1,:),cnns(bx2,:), bx1, bx2);
                if (~isempty(temp))
                    %then increment the count for nesting for idx
                    if (~isempty(this))
                        [this newq] = boxIn(temp,this,idx,q);
                        q = newq;
                    else
                        this = temp; q = idx;
                        
                    end
                    %update bx2 and bx1 as part of group
                    partofgroup(bx1) = 1; partofgroup(bx2) = 1;
                    %combine scores
                    nesting(q) = nesting(q) + 1;
                    %scores
                    if (scores(q) == 0)
                        scores(q) = this(6);
                    else
                        scores(q) = scores(q) + this(6);
                    end
                end
            end
        end
        if (isempty(this))
            this = cnns(bx1,:);
        end
        groups = [groups; this];
    end
end