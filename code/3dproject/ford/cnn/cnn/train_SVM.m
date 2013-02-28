function model = train_SVM(pos,neg,K,lambda)

tr_fea = [pos; neg]';
tr_label = [ones(size(pos,1),1); zeros(size(neg,1),1)];

% K-fold cross validation
svmtype = 'linear';
curdir = pwd;
% acc_cv = zeros(length(lambda_vec),1);
% for cc = 1:length(lambda_vec),
%     la = lambda_vec(cc);
%     if strcmp(svmtype,'linear'),
%         cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
%         options_string = sprintf('-s 1 -c %g -q -v %d -B 1', la, K);
%         acc_cv(cc) = train(tr_label,sparse(double(tr_fea)), options_string, 'col');
%     elseif strcmp(svmtype,'rbf'),
%         cd('/mnt/neocortex/scratch/kihyuks/library/libsvm-3.11/matlab/');
%         acc_cv(cc) = svmtrain(tr_label, tr_fea', sprintf('-t 2 -c %f -v %d -q',la,K));
%     end
% end
% [~,Cid] = max(acc_cv);
% Cv = lambda_vec(Cid);
cd('/mnt/neocortex/scratch/kihyuks/library/liblinear-1.8/matlab/');
options_string = sprintf('-s 1 -c %g -q -B 1', lambda);
model = train(tr_label, sparse(double(tr_fea)), options_string, 'col'); % L2 hinge loss
% pred_train = predict(tr_label, sparse(tr_fea), model, [], 'col');
cd(curdir);