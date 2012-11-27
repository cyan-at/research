function [RBM, PAR] = fobj_sparsity(RBM, PAR, pars, opt)
% Compute gradient w.r.t. sparsity regularization term
% option: 'l2', 'ce', 'sl2', 'sce' where 's' for structured
% input: PAR.poshidprobs, PAR.poshidact
% output: PAR.dW_total, PAR.dh_total

eta_sparsity = 0.9;
if strcmp(pars.optsp,'l2'),
    % l2 sparsity regularizer
    if isempty(PAR.runningavg_prob), PAR.runningavg_prob = sum(PAR.poshidact,2)/opt.batchSize;
    else PAR.runningavg_prob = eta_sparsity*PAR.runningavg_prob + (1-eta_sparsity)*sum(PAR.poshidact,2)/opt.batchSize;
    end
    dW_reg = 0;
    dh_reg = pars.pBias-PAR.runningavg_prob;
    
elseif strcmp(pars.optsp,'ce'),
    % cross-entropy sparsity regularizer
    
elseif strcmp(pars.optsp,'sl2'),
    % structured l2 sparsity regularizer
    poshidprobs_temp = sum(PAR.poshidprobs.^2,3);
    poshidact_temp = sum(sqrt(poshidprobs_temp),2)/pars.sub;
    if isempty(PAR.runningavg_prob), PAR.runningavg_prob = poshidact_temp/opt.batchSize;
    else PAR.runningavg_prob = eta_sparsity*PAR.runningavg_prob + (1-eta_sparsity)*poshidact_temp/opt.batchSize;
    end
    dW_reg = 0;
    dh_reg = (pars.pBias-PAR.runningavg_prob);
    
elseif strcmp(pars.optsp,'sce'),
    % structured cross-entropy sparsity regularizer
    poshidprobs_temp = sum(PAR.poshidprobs.^2,3);
    poshidact_temp = sum(sqrt(poshidprobs_temp),2)/pars.sub;
    if isempty(PAR.runningavg_prob), PAR.runningavg_prob = poshidact_temp/opt.batchSize;
    else PAR.runningavg_prob = eta_sparsity*PAR.runningavg_prob + (1-eta_sparsity)*poshidact_temp/opt.batchSize;
    end
    nanid1 = find(double(PAR.runningavg_prob) < eps);
    nanid2 = find(double(PAR.runningavg_prob) > 1-eps);
    
    poshidprobs_temp = sum((PAR.poshidprobs.^2).*(1-PAR.poshidprobs),3)./sqrt(sum(PAR.poshidprobs.^2,3));
    nanid3 = find(isnan(double(poshidprobs_temp))==1);
    if ~isempty(nanid3), poshidprobs_temp(nanid3) = 0; end
    poshidprobs_temp = sum(poshidprobs_temp,2)/opt.batchSize/pars.sub;
    
    if isempty(PAR.runningavg_dh), PAR.runningavg_dh = poshidprobs_temp;
    else PAR.runningavg_dh = eta_sparsity*PAR.runningavg_dh + (1-eta_sparsity)*poshidprobs_temp;
    end
    dW_reg = 0;
    dh_reg = (pars.pBias/PAR.runningavg_prob-(1-pars.pBias)/(1-PAR.runningavg_prob)).*PAR.runningavg_dh;
    if ~isempty(nanid1), dh_reg(nanid1) = pars.pBias; end
    if ~isempty(nanid2), dh_reg(nanid2) = -(1-pars.pBias)*pars.sub; end
end

% update
PAR.dW_total = PAR.dW_total + pars.sparsityLambda*dW_reg;
PAR.dh_total = PAR.dh_total + pars.sparsityLambda*dh_reg;

return;
