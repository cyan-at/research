function detections = getCVPRDetection(detectionfile)
    im = imread(detectionfile);
    offset = 2;
    labels = imcrop(im,[offset*616,0,616,808]);
    l = labels(:,:,1);
    l = l / 128;
    stats = regionprops(l,'BoundingBox');
    BB = stats.BoundingBox;
    find(
end