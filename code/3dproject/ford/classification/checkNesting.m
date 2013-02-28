function groups = checkNesting(cnns)
    groups = [];
    partofgroup = zeros(size(cnns,1),1);
    for bx1 = 1:size(cnns,1)
        %this one's groups
        %disp(num2str(cnns(bx1,:)));
        if (partofgroup(bx1) == 1); continue; end;
        this = [];
        for bx2 = 1:size(cnns,1)
            if (partofgroup(bx2) == 1); continue; end;
            if (bx1 ~= bx2)
                temp = boxIn(cnns(bx1,:),cnns(bx2,:));
                if (~isempty(temp))
                    %disp('found one!');
                    if (~isempty(this))
                        this = boxIn(temp,this);
                    else
                        this = temp;
                    end
                    %update bx2 and bx1 as part of group
                    partofgroup(bx1) = 1; partofgroup(bx2) = 1;
                    %combine scores
                end
            end
        end
        if (isempty(this))
            %disp('not paired up');
            this = cnns(bx1,:);
        end
        groups = [groups; this];
    end
    %disp(size(groups,1));
end