function [RBM, PAR] = fobj_rbm(RBM, PAR, pars, opt)
% Compute gradients using CD
% input: vis, W, hbias, vbias
% output: PAR.dW_total, PAR.dh_total, PAR.dv_total
% monitor: PAR.ferr, PAR.sparsity, PAR.recon_err

% positive phase
PAR.poshidprobs = sigmoid(pars.C_sigm/pars.sigma*(RBM.W'*PAR.vis + repmat(RBM.hbias,[1 size(PAR.vis,2)])));
PAR.posprods = PAR.vis*PAR.poshidprobs';
PAR.poshidact = squeeze(sum(PAR.poshidprobs,2));
PAR.posvisact = squeeze(sum(PAR.vis,2));

if pars.optgpu, PAR.poshidstates = GPUsingle(rand(size(PAR.poshidprobs))) < PAR.poshidprobs;
elseif pars.optjacket, PAR.poshidstates = grand(size(PAR.poshidprobs)) < PAR.poshidprobs;
else PAR.poshidstates = rand(size(PAR.poshidprobs)) < PAR.poshidprobs;
end

% reconstruction
PAR.reconst = pars.sigma*RBM.W*PAR.poshidprobs + repmat(RBM.vbias,[1 size(PAR.poshidprobs,2)]);
PAR.negdata = pars.sigma*RBM.W*PAR.poshidstates + repmat(RBM.vbias,[1 size(PAR.poshidstates,2)]);

% negative phase (CD-K)
PAR.neghidprobs = sigmoid(pars.C_sigm/pars.sigma*(RBM.W'*PAR.negdata + repmat(RBM.hbias,[1 size(PAR.negdata,2)])));
if pars.K_CD > 1
    for k_cd = 1:pars.K_CD-1
        if pars.optgpu, PAR.neghidstates = GPUsingle(rand(size(PAR.neghidprobs))) < PAR.neghidprobs;
        elseif pars.optjacket, PAR.neghidstates = grand(size(PAR.neghidprobs)) < PAR.neghidprobs;
        else PAR.neghidstates = rand(size(PAR.neghidprobs)) < PAR.neghidprobs;
        end
        PAR.negdata = pars.sigma*RBM.W*PAR.neghidstates + repmat(RBM.vbias,[1 size(PAR.neghidstates,2)]);
        PAR.neghidprobs = sigmoid(pars.C_sigm/pars.sigma*(RBM.W'*PAR.negdata + repmat(RBM.hbias,[1 size(PAR.negdata,2)])));
    end
end
PAR.negprods = PAR.negdata*PAR.neghidprobs';
PAR.neghidact = squeeze(sum(PAR.neghidprobs,2));
PAR.negvisact = squeeze(sum(PAR.negdata,2));

% error and sparsity
PAR.ferr = sum(sum((PAR.vis - PAR.reconst).^2))/(opt.batchSize*pars.numVis*pars.ws^2);
PAR.sparsity = sum(sum(PAR.poshidprobs))/(opt.batchSize*pars.num_hid);
PAR.recon_err = squeeze(sum((PAR.vis - PAR.reconst).^2,2))/opt.batchSize;

if pars.optgpu, PAR.dW_total = (PAR.posprods-PAR.negprods)/opt.batchSize - pars.l2reg*RBM.W - pars.l1reg*((RBM.W>0)*2-1);
elseif pars.optjacket, PAR.dW_total = (PAR.posprods-PAR.negprods)/opt.batchSize - pars.l2reg*RBM.W - pars.l1reg*((RBM.W>0)*2-1);
else PAR.dW_total = (PAR.posprods-PAR.negprods)/opt.batchSize - pars.l2reg*RBM.W - pars.l1reg*((RBM.W>0)*2-1);
end
PAR.dh_total = sum(PAR.poshidact-PAR.neghidact,2)/opt.batchSize;
PAR.dv_total = sum(PAR.posvisact-PAR.negvisact,2)/opt.batchSize;

return;