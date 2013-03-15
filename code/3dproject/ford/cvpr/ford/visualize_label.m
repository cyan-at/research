function img_1 = visualize_label(label)
%label is the matrix read from a label file
color_stanford=[128 128 128
    128 128 0
    128 64 128
    0 128 0
    0 0 128
    128 0 0
    128 80 0
    255 128 0]/256;
nclass=size(color_stanford,1);
[h,w]=size(label);
img_1=zeros(h,w,3);
for c=1:nclass,
    ind=find(label==c);
    img_1(ind)=color_stanford(c,1);
    img_1(ind+h*w)=color_stanford(c,2);
    img_1(ind+h*w*2)=color_stanford(c,3);
end
end