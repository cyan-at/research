function [o, inside] = getOverlapDet(group, mapped, threshold)
%o is the index in mapped of a bounding box that overlaps or is inside of
%group
o = 0; inside = 0;
box = group(1:4);
% for t = 1:size(mapped,1)
%     temp = boxIn(group,mapped(t,:));
%     if (~isempty(temp))
%         inside = 1;
%         o = t;
%         return;
%     end
% end

amt = boxoverlap(mapped, box);
q = max(amt);
%disp(amt);
if (q > threshold)
    %disp('replacing!');
    t = find(amt==q);
    temp = boxIn(group,mapped(t,:));
    if (~isempty(temp))
        inside = 1;
        o = t;
    end
else
end
%if there are no clusters for this bounding box that overlap at all, then
%mark it for deletion
if (sum(amt) < 0.2 || group(6) < 0.7)
   o = -1; 
end
end