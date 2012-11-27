function [fname_pre, pars, RBM] = rbmFirstLayer(fea_all, pars, load_result)
warning off all;
opt.verbose = 1;
opt.batchSize = pars.batchSize;
%% addpath
addpath(genpath('~/trunk/scspm/library/modules/gwt/'));
addpath /mnt/neocortex/scratch/kihyuks/library/gpumat;

%% dataset path
if ~isempty(fea_all),
    pars.numVis = size(fea_all,1)/pars.ws^2;
else
    if strcmp(pars.dataname,'caltech101')
        classes = 1:102;
        data = '101_objectcategories';
    elseif strcmp(pars.dataname,'caltech256')
        classes = 1:257;
        data = '';
    elseif strcmp(pars.dataname,'pascal2007')
        classes = 1;
        data = '';
    else strcmp(pars.dataname,'15scenes')
        classes = 1:15;
        data = '15scenes_orig-hog_grid8';
    end
    pars.classes = classes;
    if isempty(pars.dataSet), pars.dataSet = data; end
    data_dir = sprintf('%s/%s',pars.dataPath,pars.dataSet);
    subfolders = dir(data_dir);
    [cuimg] = load_sift_fea_allture(pars.classes, subfolders, data_dir);
end

initialmomentum  = 0.5;
finalmomentum    = 0.9;

% fixed parameters
k_saveon = 1; % save results on every k_saveon epochs

rbm_init;
disp(pars);

if pars.optlambda == 0, pars.sparsityLambda = pars.pBiasLambda; end
if pars.optpbias, pars.pBias = pars.pBiasMin; end

rand('state',0);
randn('state',0);
if pars.optjacket,
    grand('state',0);
    grandn('state',0);
end

%% learning
for t=t0:pars.numTrials
    % load sift fea_alltures idx
    if isempty(fea_all),
        if t == t0, [imidx_batch] = loadDataIdx(cuimg, pars);
        else imidx_batch = randsample(imidx_batch,length(imidx_batch));
        end
        num_iter = length(imidx_batch);
    else
        imidx_batch = randperm(size(fea_all,2));
        num_iter = min(floor(size(fea_all,2)/pars.batchSize),500);
    end
    step_size = pars.stepSize;
    % momentum update
    if t < pars.momch,
        momentum = initialmomentum;
        if pars.optsigma, eta_sigma = 0.001;
        else eta_sigma = 0.01;
        end
    else
        momentum = finalmomentum;
        eta_sigma = 0.01;
        pars.l1reg = 0;
    end
    
    t20s = tic;
    
    % monitoring variables
    ferr_current_iter = zeros(num_iter,1);
    sparsity_curr_iter = zeros(num_iter,1);
    recon_err_for_sigma_epoch = 0;
    tetot = zeros(num_iter,1);
    
    for i = 1:num_iter
        if pars.opteps && t < pars.momch, epsilon = 0.005;
        else epsilon = pars.epsilon/(1+pars.epsDecay*t); end
        
        % generate random patch
        if isempty(fea_all),
            [vis,~,~,~,~] = generate_patch(pars, i, imidx_batch, cuimg, subfolders, data_dir);
        else
            vis = fea_all(:,imidx_batch((i-1)*pars.batchSize+1:i*pars.batchSize));
        end
        
        if pars.optgpu, PAR.vis = gpusingle(vis);
        elseif pars.optjacket, PAR.vis = gsingle(vis);
        else PAR.vis = vis;
        end
        
        % show progress in epoch
        %         if opt.verbose, fprintf(1,'epoch %d image %d/%d iteration %d/%d, winc: %g, hbiasinc: %g, vbiasinc: %g\n',t, imidx_batch(i), cuimg(end), i, num_iter, sum(winc(:).^2)/pars.num_hid, sum(hbiasinc(:).^2)/pars.num_hid, sum(vbiasinc(:).^2)/pars.num_hid); end
        
        % update rbm
        teptot = 0;
        tsp = tic;
        
        % compute gradient using cd
        [RBM, PAR] = fobj_rbm(RBM, PAR, pars, opt);
        
        % compute gradient w.r.t. sparsity regularization
        [RBM, PAR] = fobj_sparsity(RBM, PAR, pars, opt);
        
        % monitoring variables
        ferr_current_iter(i) = PAR.ferr;
        sparsity_curr_iter(i) = PAR.sparsity;
        recon_err_for_sigma_epoch = recon_err_for_sigma_epoch + PAR.recon_err;
        
        % time
        tep = toc(tsp);
        teptot = teptot + tep;
        tetot(i) = teptot;
        
        % update parameters
        PAR.Winc = momentum*PAR.Winc + epsilon*PAR.dW_total;
        RBM.W = RBM.W + PAR.Winc;
        
        PAR.vbiasinc = momentum*PAR.vbiasinc + epsilon*PAR.dv_total;
        RBM.vbias = RBM.vbias + PAR.vbiasinc;
        
        PAR.hbiasinc = momentum*PAR.hbiasinc + epsilon*PAR.dh_total;
        RBM.hbias = RBM.hbias + PAR.hbiasinc;
        
        % print every 20 inner iterations
        if mod(i, 20)==0,
            if pars.optlambda == 1, if pars.sparsityLambda < pars.pBiasLambda, pars.sparsityLambda = pars.sparsityLambda + step_size*20/num_iter; end; end;
            t20e = toc(t20s);
            if opt.verbose,
                mean_err = mean(ferr_current_iter(i-19:i));
                mean_sparsity = mean(sparsity_curr_iter(i-19:i));
%                 fprintf('epoch:%d, iteration %d/%d, err= %g, sparsity= %g mean(hbias)= %g,  mean(vbias)= %g, sigm = %g\n',t, i, num_iter, mean_err, mean_sparsity, mean(RBM.hbias), mean(RBM.vbias), pars.sigma);
%                 if pars.optgpu, fprintf('||w|| = %g, ||dw|| = %g, time = %g, gpumem = %g\n ', sqrt(sum(RBM.W(:).^2)), sqrt(sum(PAR.dW_total(:).^2)),t20e,gpumem);
%                 else fprintf('||w|| = %g, ||dw|| = %g, time = %g\n ', sqrt(sum(RBM.W(:).^2)), sqrt(sum(PAR.dW_total(:).^2)),t20e);
%                 end
            end
            t20s = tic;
        end
    end
    % update sigma using reconstruction error
    if pars.optlambda == 2,
        if pars.sparsityLambda < pars.pBiasLambda, pars.sparsityLambda = pars.sparsityLambda + step_size; end
    end
    error_history(t) = mean(ferr_current_iter);
    sparsity_history(t) = mean(sparsity_curr_iter);
    hbias_history(t) = mean(RBM.hbias);
    vbias_history(t) = mean(RBM.vbias);
    wnorm_history(t) = sqrt(sum(RBM.W(:).^2)/pars.num_hid);
    sigma_history(t) = pars.sigma;
    
    fprintf('epoch %d error = %g \tsparsity_hid = %g\n', t, mean(ferr_current_iter), mean(sparsity_curr_iter));
    RBM.W = single(RBM.W); RBM.vbias = single(RBM.vbias); RBM.hbias = single(RBM.hbias); winc = single(PAR.Winc); vbiasinc = single(PAR.vbiasinc); hbiasinc = single(PAR.hbiasinc); runningavg_prob = single(PAR.runningavg_prob);
    if mod(t, k_saveon)==0
        save(fname_mat, 'pars', 't', 'error_history', 'sparsity_history', 'hbias_history', 'vbias_history', 'wnorm_history','imidx_batch','sigma_history','RBM','winc','vbiasinc','hbiasinc','runningavg_prob');
%         disp(sprintf('results saved as %s\n', fname_mat));
    end
    if mod(t, 10) == 0
        fprintf('epoch=%d, err= %g, sparsity= %g, mean(hbias)= %g, mean(vbias)= %g, learning time per epoch = %.4g\n', t, mean_err, mean_sparsity, mean(RBM.hbias), mean(RBM.vbias), sum(tetot)/t);
        fname_timestamp_save = sprintf('%s_%04d.mat', fname_prefix_int, t);
        save(fname_timestamp_save, 'RBM', 'pars', 't', 'error_history', 'sparsity_history');
    end
    if pars.optgpu, RBM.W = gpusingle(RBM.W); RBM.vbias = gpusingle(RBM.vbias);RBM.hbias = gpusingle(RBM.hbias);
    elseif pars.optjacket, RBM.W = gsingle(RBM.W); RBM.vbias = gsingle(RBM.vbias);RBM.hbias = gsingle(RBM.hbias);
    end
    
    % update sigma using reconstruction error
    pars.sigma = pars.sigma*(1-eta_sigma) + eta_sigma*sqrt(mean(recon_err_for_sigma_epoch/num_iter));
end
RBM.sigma = pars.sigma;
RBM.W = double(RBM.W);
RBM.hbias = double(RBM.hbias);
RBM.vbias = double(RBM.vbias);
return;
