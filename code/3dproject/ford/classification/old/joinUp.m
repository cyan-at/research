function newbox = joinUp(groups,c2)
%temp = joinUp(groups,c2);
selection = groups(c2,:);
x1 = max(selection(:,1));
y1 = max(selection(:,2));
x2 = min(selection(:,3));
y2 = min(selection(:,4));
cam = mode(selection(:,5));
score = mean(selection(:,6));
newbox = [x2,y2,x1,y1,cam,score];
end