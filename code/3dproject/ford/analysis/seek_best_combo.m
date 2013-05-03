% %load data
% saveName = 'train_plus_interv5_num200';
% [neg_scores,pos_scores] = gatherData(5,200,saveName); %saves it in locations

%overhead
cnnfeature = struct(); cnnfeature.matrix_idx = 1; cnnfeature.name = 'CNN';
twofeature = struct(); twofeature.matrix_idx = 2; twofeature.name = '2D';
threefeature = struct(); threefeature.matrix_idx = 3; threefeature.name = '3D';

bestAP = [];
pos_weight_selection = 0.1:0.1:2;
neg_weight_selection = 0.1:0.1:2;
opt_standardizes = [true,false];
iteration_steps = 1:5;

bestAP = 0.0;
bestOptStandardize = false;
bestposWeight = 0.1;
bestnegWeight = 0.1;
bestIterationStep = 1;
exp_desc = 'search_across_parameters';
for i = 1:length(pos_weight_selection)
    for j = 1:length(neg_weight_selection)
        for k = 1:2
            for l = 1:5
                posWeight = pos_weight_selection(i);
                negWeight = neg_weight_selection(j);
                opt_standardize = opt_standardizes(k);
                iteration_step = iteration_steps(l);
                %set search parameters
                xfeature = cnnfeature;
                yfeature = threefeature;
                [rbfmodel,rbf_name] = train_rbf_model(exp_desc,pos_scores,neg_scores,xfeature,yfeature,posWeight,negWeight,opt_standardize);
                %save the model
                ap = refine_test(rbfmodel,rbf_name,exp_desc,iteration_step,xfeature,yfeature,opt_standardize);
                if (ap > bestAP)
                    bestAP = ap;
                    bestOptStandardize = opt_standardize;
                    bestposWeight = posWeight;
                    bestnegWeight = negWeight;
                    bestIterationStep = iteration_step;
                end
            end
        end
    end
end