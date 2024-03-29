% %load data
% saveName = 'train_plus_interv5_num200';
% [neg_scores,pos_scores] = gatherData(5,200,saveName); %saves it in locations
[neg_scores,pos_scores] = gatherTestData(5);

%overhead
set(0,'DefaultFigureVisible','off');
cnnfeature = struct(); cnnfeature.matrix_idx = 1; cnnfeature.name = 'CNN';
twofeature = struct(); twofeature.matrix_idx = 2; twofeature.name = '2D';
threefeature = struct(); threefeature.matrix_idx = 3; threefeature.name = '3D';

bestAP = [];
pos_weight_selection = 0.1:0.1:2;
neg_weight_selection = 0.1:0.1:2;
opt_standardizes = [true,false];
iteration_steps = 1:5;

bestAP = struct();
bestAP.opt_standardize = false;
bestAP.ap = 0.0;
bestAP.rc = [];
bestAP.pc = [];
bestAP.bestposWeight = 0.1;
bestAP.bestnegWeight = 0.1;
bestAP.bestIterationStep = 1;
bestAPfile = sprintf('%s/bestap.mat',pwd);

% bestAP = 0.0;
% bestOptStandardize = false;
% bestposWeight = 0.1;
% bestnegWeight = 0.1;
% bestIterationStep = 1;
exp_desc = 'search_across_parameters_test';
for i = 3:length(pos_weight_selection)
    for j = 1:length(neg_weight_selection)
        for k = 1:2
            for l = 5:5
                posWeight = pos_weight_selection(i);
                negWeight = neg_weight_selection(j);
                opt_standardize = opt_standardizes(k);
                iteration_step = iteration_steps(l);
                %set search parameters
                xfeature = cnnfeature;
                yfeature = threefeature;
                [rbfmodel,rbf_name] = train_rbf_model(exp_desc,pos_scores,neg_scores,xfeature,yfeature,posWeight,negWeight,opt_standardize);
                %save the model
                m = refine_test(rbfmodel,rbf_name,exp_desc,iteration_step,xfeature,yfeature,opt_standardize);
                if (m.ap > bestAP.ap)
                    bestAP.opt_standardize = opt_standardize;
                    bestAP.ap = m.ap;
                    bestAP.rc = m.rc;
                    bestAP.pc = m.pc;
                    bestAP.bestposWeight = posWeight;
                    bestAP.bestnegWeight = negWeight;
                    bestAP.bestIterationStep = iteration_step;
                    bestAPfile = sprintf('%s/bestap.mat',pwd);
                    fprintf('Best AP: %2.2f\n',bestAP.ap);
                    save(bestAPfile,'bestAP');
                end
            end
        end
    end
end