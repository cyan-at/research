function hash = VOChash_init(strs)
disp(strs)
hsize=4999;
hash.key=cell(hsize,1);
hash.val=cell(hsize,1);

for i=1:numel(strs)
    s=strs{i};
%     disp(s([6 8 10:end]));
    disp(s)
%     h=mod(str2double(s([6 8 10:end])),hsize)+1;
    h=mod(str2double(s),hsize)+1;
    j=numel(hash.key{h})+1;
    hash.key{h}{j}=strs{i};
    hash.val{h}(j)=i;
end

