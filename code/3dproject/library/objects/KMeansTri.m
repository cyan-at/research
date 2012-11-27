classdef KMeansTri < handle   
    properties
        centroids;
        numHidden;
        % mode = 'hard';% or triangle or hardreal
        verbose = false;
        standardize = false;
        mu = [];
        stdev = [];
        savepath = '';
        gmmparams;
    end
    
    methods
        function self = KMeansTri(numHidden, opt_standardize)
            self.numHidden = numHidden;
            self.centroids = []; 
            self.standardize = opt_standardize;
        end

        % patches: features*samples
        % centroids: features*numHidden
        function train(self, patches, num_iter)
            if self.standardize
                [patches self.mu self.stdev] = standardize_col(patches);
            end
            
            if ~exist('num_iter', 'var')
                if self.numHidden < 1024
                    num_iter = 100; % usually it's worth spending some time training with more iterations
                else
                    num_iter = 200;
                end
            end
            
            [label, center] = litekmeans_col(patches, self.numHidden, true, num_iter);
            self.centroids = center;
            
            % store GMM parameters just in case
            self.gmmparams = [];
            
            % initialize GMMs
            n = size(patches,2);
            E = sparse(1:n, label, 1, n, self.numHidden, n)';  % transform label into indicator matrix
            
            % initial GMM paramters
            p0 = full(mean(E,2)); % it does not need to be a sparse matrix
            %mu = center;
            sigma = sqrt(mean(mean( (patches - center(:, label)).^2, 2))); % Using sigma*I in this example

            self.gmmparams.p0 = p0;
            %GMM.mu = mu;
            self.gmmparams.sigma = sigma;            

            if(self.verbose), fprintf('done\n'); end
        end
        
        function [features] = computeActivations(self, patches, varargin)
            if self.standardize
                patches = standardize_col(patches, self.mu, self.stdev);
            end
            % compute 'triangle' activation function
            xx = sum(patches.^2, 1); % 1*N vector (N:#examples)
            cc = sum(self.centroids.^2, 1)'; % K*1 vector
            % xc = patches * centroids';
            
            % z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*centroids'*patches)) ); % distances
            z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*self.centroids'*patches)) ); % distances
            
            [v,inds] = min(z,[],1);
            mu = mean(z, 1); % average distance to centroids for each patch
            features = max(bsxfun(@minus, mu, z), 0);
        end
    end
    
end
