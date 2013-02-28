function demo_hog_conv_svm(savePath)
if isdir(savePath) == 0
    mkdir(savePath);
end
cnn2('faces','hog',[],'J',savePath) % should get .9524 AP for test data and good looking filter