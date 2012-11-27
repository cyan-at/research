classdef KMeansHard < handle   
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
        function self = KMeansHard(numHidden, opt_standardize)
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

            [val,label] = max(bsxfun(@minus,self.centroids'*patches,0.5*sum(self.centroids.^2,1)')); % assign samples to the nearest centers
            n = size(patches,2);
            E = sparse(1:n,label,1,n,self.numHidden,n)';  % transform label into indicator matrix
            features = E;
        end
    end
    
end
