%% RBM initialization or load parameters
if ~isfield(pars,'es'), pars.es = pars.ws; end
if ~isfield(pars,'opttfinit'), pars.opttfinit = 0; end
fname_gmm = sprintf('gmm_%s_b%d_ws%d.mat',pars.dataSet,pars.num_hid);
fname_rbminit = sprintf('%s/rbm_%s_b%d_ws%d_es%d_tf%d.mat',pars.gmmSavePath,pars.dataSet,pars.num_hid,pars.ws,pars.es,pars.opttfinit);
if isempty(load_result),
    %% new feature learning
    t0 = 1;
    %% Initialize RBM pars
    if pars.optgmminit,
        % initialize RBM with GMM
        try
            load(fname_rbminit,'RBM','sigma0','GMM');
        catch
            if pars.num_hid <= 1024, optiter = 0;
            else optiter = 0; end
            [RBM sigma0 GMM KM] = gmm2rbm(fea_all, optiter, pars);
            save(fname_rbminit,'RBM','sigma0','GMM','KM');
            save(sprintf('%s/%s',pars.gmmsavepath,fname_gmm),'GMM','KM','pars');
        end
        pars.sigma = sigma0;
        pars.std_gaussian = sqrt(pars.sigma);
        if pars.opthid
            RBM.hbias = RBM.hbias - 2*log(pars.ws);
        end
    else
        try
            load(fname_rbminit,'sigma0','GMM');
        catch
            if pars.num_hid <= 1024, optiter = 0;
            else optiter = 0; end
            [RBM sigma0 GMM KM] = gmm2rbm(fea_all, optiter, pars);
            save(fname_rbminit,'RBM','sigma0','GMM','KM');
            save(sprintf('%s/%s',pars.gmmSavePath,fname_gmm),'GMM','KM','pars');
            clear RBM;
        end
        pars.sigma = sigma0;
        pars.std_gaussian = sqrt(pars.sigma);
    end
    
    if ~exist('RBM', 'var'),
        RBM.W = 0.02*randn(pars.numVis*pars.ws^2, pars.num_hid);
        RBM.vbias = zeros(pars.numVis*pars.ws^2,1);
        RBM.hbias = zeros(pars.num_hid,1);
    end
    error_history = [];
    sparsity_history = [];
    hbias_history = [];
    vbias_history = [];
    Wnorm_history = [];
    
    datelearn = datestr(now, 30);
    fname_pre = sprintf('rbm_%s_w%d_b%02d_gmm%d_p%g_plambda%g_sp%s_date_%s', pars.dataSet, pars.ws, pars.num_hid, pars.optgmminit, pars.pBias, pars.pBiasLambda, pars.optsp, datelearn); % TEST version
    fname_prefix = sprintf('%s/main/%s',pars.savePath,fname_pre);
    fname_prefix_int = sprintf('%s/%s',pars.savePath,fname_pre);
    fprintf('%s\n',fname_prefix);
    %% Initialize GPU parameters if necessary
    if pars.optgpu,
        addpath /mnt/neocortex/scratch/kihyuks/library/GPUmat/;
        GPUstartnum(pars.optgpu-1);
        RBM.W = GPUsingle(RBM.W); %
        RBM.hbias = GPUsingle(RBM.hbias);
        RBM.vbias = GPUsingle(RBM.vbias);
        PAR.Winc = GPUsingle(zeros(size(RBM.W)));
        PAR.hbiasinc = GPUsingle(zeros(size(RBM.hbias)));
        PAR.vbiasinc = GPUsingle(zeros(size(RBM.vbias)));
        PAR.dW_total = GPUsingle(zeros(size(RBM.W)));
        PAR.dh_total = GPUsingle(zeros(size(RBM.hbias)));
        PAR.dv_total = GPUsingle(zeros(size(RBM.vbias)));
        PAR.poshidprobs = GPUsingle(zeros(pars.num_hid,pars.batchSize));
        PAR.posprods = GPUsingle(zeros(pars.numVis*pars.ws^2,pars.num_hid));
        PAR.neghidprobs = GPUsingle(zeros(size(PAR.poshidprobs)));
        PAR.negprods = GPUsingle(zeros(size(PAR.posprods)));
        PAR.vis = GPUsingle(zeros(pars.numVis,pars.batchSize));
        PAR.negdata = GPUsingle(zeros(size(PAR.vis*pars.ws^2)));
        PAR.reconst = GPUsingle(zeros(size(PAR.vis*pars.ws^2)));
        PAR.recon_err = GPUsingle(zeros(pars.numVis*pars.ws^2,1));
        PAR.poshidact = GPUsingle(zeros(pars.num_hid,1));
        PAR.posvisact = GPUsingle(zeros(pars.numVis*pars.ws^2,1));
        PAR.neghidact = GPUsingle(zeros(pars.num_hid,1));
        PAR.negvisact = GPUsingle(zeros(pars.numVis*pars.ws^2,1));
    elseif pars.optjacket,
        addpath /usr/local/jacket/engine/
        gactivate;
        gselect(pars.optjacket-1);
        RBM.W = gsingle(RBM.W); %
        RBM.hbias = gsingle(RBM.hbias);
        RBM.vbias = gsingle(RBM.vbias);
        PAR.Winc = gzeros(size(RBM.W));
        PAR.hbiasinc = gzeros(size(RBM.hbias));
        PAR.vbiasinc = gzeros(size(RBM.vbias));
        PAR.dW_total = gzeros(size(RBM.W));
        PAR.dh_total = gzeros(size(RBM.hbias));
        PAR.dv_total = gzeros(size(RBM.vbias));
        PAR.poshidprobs = gzeros(pars.num_hid,pars.batchSize);
        PAR.posprods = gzeros(pars.numVis*pars.ws^2,pars.num_hid);
        PAR.neghidprobs = gzeros(size(PAR.poshidprobs));
        PAR.negprods = gzeros(size(PAR.posprods));
        PAR.vis = gzeros(pars.numVis*pars.ws^2,pars.batchSize);
        PAR.negdata = gzeros(size(PAR.vis));
        PAR.reconst = gzeros(size(PAR.vis));
        PAR.recon_err = gzeros(pars.numVis*pars.ws^2,1);
        PAR.poshidact = gzeros(pars.num_hid,1);
        PAR.posvisact = gzeros(pars.numVis*pars.ws^2,1);
        PAR.neghidact = gzeros(pars.num_hid,1);
        PAR.negvisact = gzeros(pars.numVis*pars.ws^2,1);
    else
        PAR.Winc = zeros(size(RBM.W));
        PAR.hbiasinc = zeros(size(RBM.hbias));
        PAR.vbiasinc = zeros(size(RBM.vbias));
    end
    PAR.runningavg_prob = [];
else	% resume for more iteration
    fname_pre = load_result;
    fname_prefix = sprintf('%s/main/%s',pars.savepath,load_result);
    fname_prefix_int = sprintf('%s/%s',pars.savepath,fname_pre);
    
    fprintf('%s\n',fname_prefix);
    load(sprintf('%s/main/%s.mat',pars.savePath,load_result));
    
    t0 = t+1;
    pars.numTrials = pars.numTrials + 30;
    %% Initialize GPU parameters if necessary
    if pars.optgpu,
        GPUstartnum(pars.optgpu-1);
        RBM.W = GPUsingle(RBM.W);
        RBM.hbias = GPUsingle(RBM.hbias);
        RBM.vbias = GPUsingle(RBM.vbias);
        PAR.Winc = GPUsingle(Winc);
        PAR.hbiasinc = GPUsingle(hbiasinc);
        PAR.vbiasinc = GPUsingle(vbiasinc);
        PAR.dW_total = GPUsingle(zeros(size(RBM.W)));
        PAR.dh_total = GPUsingle(zeros(size(RBM.hbias)));
        PAR.dv_total = GPUsingle(zeros(size(RBM.vbias)));
        PAR.poshidprobs = GPUsingle(zeros(pars.num_hid,pars.batchSize));
        PAR.posprods = GPUsingle(zeros(pars.numVis*pars.ws^2,pars.num_hid));
        PAR.neghidprobs = GPUsingle(zeros(size(PAR.poshidprobs)));
        PAR.negprods = GPUsingle(zeros(size(posprods)));
        PAR.vis = GPUsingle(zeros(pars.numVis*pars.ws^2,pars.batchSize));
        PAR.negdata = GPUsingle(zeros(size(vis)));
        PAR.reconst = GPUsingle(zeros(size(vis)));
        PAR.runningavg_prob = GPUsingle(PAR.runningavg_prob);
        PAR.recon_err = GPUsingle(zeros(pars.numVis*pars.ws^2,1));
        PAR.poshidact = GPUsingle(zeros(pars.num_hid,1));
        PAR.posvisact = GPUsingle(zeros(pars.numVis*pars.ws^2,1));
        PAR.neghidact = GPUsingle(zeros(pars.num_hid,1));
        PAR.negvisact = GPUsingle(zeros(pars.numVis*pars.ws^2,1));
    elseif pars.optjacket,
        addpath /usr/local/jacket/engine/
        gactivate;
        gselect(pars.optjacket-1);
        RBM.W = gsingle(RBM.W);
        RBM.hbias = gsingle(RBM.hbias);
        RBM.vbias = gsingle(RBM.vbias);
        PAR.Winc = gsingle(Winc);
        PAR.hbiasinc = gsingle(hbiasinc);
        PAR.vbiasinc = gsingle(vbiasinc);
        PAR.dW_total = gzeros(size(RBM.W));
        PAR.dh_total = gzeros(size(RBM.hbias));
        PAR.dv_total = gzeros(size(RBM.vbias));
        PAR.poshidprobs = gzeros(pars.num_hid,pars.batchSize);
        PAR.posprods = gzeros(pars.numVis*pars.ws^2,pars.num_hid);
        PAR.neghidprobs = gzeros(size(PAR.poshidprobs));
        PAR.negprods = gzeros(size(posprods));
        PAR.vis = gzeros(pars.numVis*pars.ws^2,pars.batchSize);
        PAR.negdata = gzeros(size(vis));
        PAR.reconst = gzeros(size(vis));
        PAR.runningavg_prob = gsingle(PAR.runningavg_prob);
        PAR.recon_err = gzeros(pars.numVis*pars.ws^2,1);
        PAR.poshidact = gzeros(pars.num_hid,1);
        PAR.posvisact = gzeros(pars.numVis*pars.ws^2,1);
        PAR.neghidact = gzeros(pars.num_hid,1);
        PAR.negvisact = gzeros(pars.numVis*pars.ws^2,1);
    end
end

%% save file path
fname_save = sprintf('%s', fname_prefix);
fname_mat  = sprintf('%s.mat', fname_save);
fname_out = fname_mat;
mkdir(fileparts(fname_save));
fname_out;


