function demo_pixel_conv_svm(savePath)

if isdir(savePath) == 0
    mkdir(savePath);
end
cnn2('faces','pixels',[],'J',savePath) % should get .95 AP for test data