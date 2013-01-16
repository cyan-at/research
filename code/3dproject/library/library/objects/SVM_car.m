classdef SVM_car
    %SVM_car class.
    
    properties
        
        svmType;        % 'linear' or 'rbf';
        K;              % K-fold cross validation.
        randstate;      % 
        lambda_vec;     %
        
        savePath;
        resultsPath;
    end
    
    methods
        %% Constructor.
        
        function obj = SVM_car(svmType, K, randstate)
            
            if ~exist('svmType', 'var')     svmType = 'linear';  end;
            if ~exist('K', 'var')           K = 5;               end;
            if ~exist('randstate', 'var')   randstate = 1;       end;
        
            obj.svmType = svmType;
            obj.K = K;
            obj.randstate = randstate;
            
            if strcmp(svmType,'linear'),
                obj.lambda_vec = [10000 3000 1000 300 100 30 10 3 1 0.3 0.1];
                
            elseif strcmp(svmType,'rbf'),
                obj.lambda_vec = [1e8 1e7 1e6 1e5 1e4 1e3 1e2 1e1];
            
            end
           
        end
        
        %% Train.
        
        function [ acc, acc_cv, pred_train, pred_test, model, rscore_train, rscore_test]  = train(obj, ...
                tr_fea, tr_label, ts_fea, ts_label)
            % Train SVM. tr_fea is a [ num_hid x #images ] matrix, tr_label
            % is a [ #images x 1 ] vector with labels that indicate class.
            % The same format applies for ts_fea and ts_label.
            % Output: pred_train is [ #images x 1 ] vector with each element
            % indicating predictions of that image. pred_test has the
            % same format.
            
            addpath /mnt/neocortex/scratch/kihyuks/libdeepnets/trunk/ScSPM/large_scale_svm/
            tr_label = double(tr_label);
            ts_label = double(ts_label);
            
            % K-fold cross validation
            curdir = pwd;
            acc_cv = zeros(length(obj.lambda_vec), 1);
            
            % Use different lamda values to train.
            for cc = 1:length(obj.lambda_vec),
                
                la = obj.lambda_vec(cc);
                
                if strcmp(obj.svmType, 'linear'),
                    
                    cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
                    options_string = sprintf('-s 1 -c %g -q -v %d -B 1', la, obj.K);
                    acc_cv(cc) = train(tr_label, sparse(double(tr_fea)), options_string, 'col');

                elseif strcmp(obj.svmType,'rbf'),
                    
                    cd('/mnt/neocortex/scratch/kihyuks/library/libsvm-3.11/matlab/');
                    acc_cv(cc) = svmtrain(tr_label, tr_fea', sprintf('-t 2 -c %f -v %d -q', la, obj.K));
                    
                end
            end
            
            % Set Cv to the max lambda value. Set acc_cv to the max of acc_cv array.
            [acc_cv, Cid] = max(acc_cv);
            Cv = obj.lambda_vec(Cid);
            
            % Make predictions.
            if strcmp(obj.svmType,'linear'),
                % Linear SVM prediciton.
                
                options_string = sprintf('-s 1 -c %g -q -B 1', Cv);
           
                model = train(tr_label, sparse(double(tr_fea)), options_string, 'col'); % L2 hinge loss
                
                % Save model for future use.
%                 if exist('modelCompletePath', 'var')
%                     save(modelCompletePath, 'model');
%                 end
                
                [pred_train, ~, rscore_train] = predict(tr_label, sparse(tr_fea), model, [], 'col');
                fprintf('Model learning done!!\n');
                
                clear tr_fea;
                ts_fea = double(ts_fea);
                [pred_test, acc, rscore_test] = predict(ts_label, sparse(ts_fea), model, [], 'col');
                
            elseif strcmp(obj.svmType,'rbf'),
                % RBF SVM prediction.
                
                svmmodel = svmtrain(tr_label, tr_fea', sprintf('-t 2 -c %f -q', Cv));
                [pred_train, ~, rscore_train] = svmpredict(tr_label, tr_fea', svmmodel);
                [pred_test, acc, rscore_test] = svmpredict(ts_label, ts_fea', svmmodel);
                acc = acc(1);
                
            end
            
            cd(curdir);
            fprintf('acc = %g, acc_cv = %g\n', acc, acc_cv);
        
        end
        
        %% Train & Report Result.
        
%         function reportAccTrain(obj, tr_fea, tr_label, ts_fea, ts_label, ...
%                 saveName)
%            % Train SVM and report true negative acc & true positive acc.
%            % tr_fea is a [ num_hid x #images ] matrix, tr_label is a 
%            % [ #images x 1 ] vector with labels that indicate class.
%            % The same format applies for ts_fea and ts_label.
%            % saveName is the name of .txt file in which result will be saved.
%           
%            % Train.
%            [acc, acc_cv, ~, pred_test, ~] = obj.train(tr_fea, tr_label, ts_fea, ts_label);
%            
%            % Calculate true negative acc & true positive acc.
%            not_idx = find(ts_label == 0);
%            true_neg_acc = sum(ts_label(not_idx) == pred_test(not_idx)) / length(not_idx)
%            car_idx = find(ts_label == 1);
%            true_pos_acc = sum(ts_label(car_idx) == pred_test(car_idx)) / length(car_idx)
%            
%            % Save results to a .txt file.     
%            if exist('saveName', 'var')
%                
%                resultsName = strcat(saveName, '.txt');
%                fileID = fopen(resultsName, 'w');
%                fprintf(fileID,'True Negative Accuracy: %4.2f\n', true_neg_acc);
%                fprintf(fileID,'True Positive Accuracy: %4.2f\n', true_pos_acc);
%                fprintf(fileID,'Acc: %4.2f\n', acc);
%                fprintf(fileID,'Acc CV: %4.2f\n', acc_cv);
%                fclose(fileID);
%                
%            end
%            
%         end
        
    end
    
end

