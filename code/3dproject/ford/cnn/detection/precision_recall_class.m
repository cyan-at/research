function [correct_detections detections instances precision recall thresholds] ...
    = precision_recall_class( test_set, model )
% Calculate precision/recall for a given class

test_set.sortExamplesByImPath();

% generate thresholds to use
min_thresh = 0;
max_thresh = .8;
thresholds = linspace(max_thresh, min_thresh, 50);

detections = zeros(size(thresholds));
correct_detections = zeros(size(thresholds));
instances = 0;

old_path = '';
current_boxes = cell(0);
cb_ind = 0;
last_example = '';
pos_ex = test_set.examples(test_set.pos_ind);
for ind = 1:length(test_set.pos_ind)
    if ~strcmp(pos_ex(test_set.pos_ind(ind)).im_path, old_path) && ~isempty(last_example)
        % Analyze image
        sprintf('Analyzing: %s', last_example.im_path)
        get_image_stats(last_example.getFeatPyramid(model), model, current_boxes);
        current_boxes = cell(0);
        cb_ind = 0;
    end
    
    last_example = pos_ex(ind);
    cb_ind = cb_ind + 1;
    current_boxes{cb_ind} = [last_example.x1 last_example.y1 last_example.x2 last_example.y2];
end
% Special case, last example if ~isempty(current_boxes) > 0
if ~isempty(current_boxes)
    get_image_stats(last_example.getFeatPyramid(model), model, current_boxes);
end


function get_image_stats(pyra, model, boxes)
% Updates the precision recall graph and stats by analyzing a given image
    [tmp_correct, tmp_detections, tmp_instances, ~, ~] =...
        precision_recall_image(pyra, model, boxes, thresholds);

    detections = detections + tmp_detections;
    correct_detections = correct_detections + tmp_correct;
    instances = instances + tmp_instances;
    precision = correct_detections ./ detections;
    recall = correct_detections / instances;
    %display(correct_detections);
    %display(detections);
    %display(instances);
    figure(2);
    plot(recall, precision);
    title(sprintf('Precision/Recall for %s', test_set.name));
    xlabel('Recall');
    ylabel('Precision');
end
end

