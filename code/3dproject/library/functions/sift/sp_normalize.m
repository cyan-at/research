function [fea_arr, fealen] = sp_normalize(fea_arr, threshold, suppression)
% normalize descriptors
%
% find indices of descriptors to be normalized (those whose norm is larger than 1)
fealen = sqrt(sum(fea_arr.^2, 2));

normalize_ind1 = [fealen >= threshold];
normalize_ind2 = ~normalize_ind1;

fea_arr_hcontrast = fea_arr(normalize_ind1, :);
fea_arr_hcontrast = fea_arr_hcontrast ./ repmat(fealen(normalize_ind1, :), [1 size(fea_arr,2)]);

fea_arr_lcontrast = fea_arr(normalize_ind2,:);
fea_arr_lcontrast = fea_arr_lcontrast./ threshold;

% suppress large gradients
fea_arr_hcontrast( fea_arr_hcontrast > suppression ) = suppression;
fea_arr_lcontrast( fea_arr_lcontrast > suppression ) = suppression;

% finally, renormalize to unit length
fea_arr_hcontrast = fea_arr_hcontrast ./ repmat(sqrt(sum(fea_arr_hcontrast.^2, 2)), [1 size(fea_arr,2)]);

fea_arr(normalize_ind1,:) = fea_arr_hcontrast;
fea_arr(normalize_ind2,:) = fea_arr_lcontrast;

return;
