function [label score] = get2Dscore(patch,model,encoder,parameters)
patch = imresize(patch,[250,250]);
hogfeat = calcHOG(patch);
pool = pooling(hogfeat, encoder, parameters);
pool = double(pool);
[label, ~, score] = predict(1, sparse(pool), model, [], 'col');
end