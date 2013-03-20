classdef RBM < handle
	properties
        %basics
		numHidden = 1024; %default
		numVisible;
        
        weights;
        hbiasWeights;
        vbiasWeights;

		learningRate = 0.1;
        
		k = 1;
        %according to practical guide we should initialize
        %the weights with mean 0 and variance 0.01
		sigma = 0.01;
        
        %we can split the data set into batches
        %this way we can utilize matrix multiplication
        batchSize = 1;
        
        %momentum parameters
        initialMomentum = 0.5; %initial momentum
        finalMomentum = 0.9; %final momentum
        
        %persistent CD option
        persistentCD = false;
        
        %we can also turn on monitoring to report free energy / error
        monitorFreeEnergyRate = 5;
        monitorErrorRate = 5;
        
	end
	methods
		function self = RBM(numHidden, learningRate, k, batchSize)
			%constructor function
			if exist('numHidden','var'), self.numHidden = numHidden; end;
			if exist('learningRate','var'), self.learningRate = learningRate; end;
			if exist('k','var'), self.k = k; end;
			if exist('batchSize','var'), self.batchSize = batchSize; end;
		end
		function activation = activateHidden(self, visible)
			%gets the activations for hidden units given visible units
			%self.weights is (numHidden + 1) x (numVisible + 1)
			%activation then is (numHidden + 1) x (numVisible + 1) * ((numVisible+1) x 1)
			activation = self.weights * visible;
			activation = sigmoid(activation); %(numHidden + 1)
		end
		function hiddenStates = gibbsSampleHgivenV(self,visible,reconstruction)
			%infer the state of hidden units given visible units
			%according to the RBM guide, we should sample only if hidden units driven by data, that is during CD0
			%other than that, we should use probabilities
			hiddenProb = self.activateHidden(visible);
			if (reconstruction)
				hiddenStates = hiddenProb;
			else
				hiddenStates = hiddenProb > rand(size(hiddenProb));
			end
		end
		function activation = activateVisible(self, hidden)
			%gets the activations for visible units given hidden units
			%self.weights is (numHidden + 1) x (numVisible + 1)
			%activation then is (numVisible + 1) x (numHidden + 1) * ((numHidden+1) x 1)
			activation = self.weights' * hidden;
			activation = sigmoid(activation); %(numVisible + 1)
		end
		function visibleProb = gibbsSampleVgivenH(self,hidden)
			%infer the state of visible units given hidden units
			%reconstruction step
			%we always use probabilities, do not sample
			visibleProb = self.activateVisible(hidden); %(numVisible + 1)
		end
		function [hiddenStates, visibleStates] = CDk(self, hidden, k)
			%constrastive divergence, an approximation of gradient descent
			%hidden to be numHidden x 1, visible to be numVisible x 1
			hiddenStates = hidden;
			for gibbStep = 1:k
				visibleStates = self.gibbsSampleVgivenH(hidden);
				hiddenStates = self.gibbsSampleHgivenV(visibleStates, true);
			end
		end
		function train(self, data, numEpochs)
			addpath ../functions
			%let data be of the form sampleSize x numSamples, columns and columns of samples
			if ~isempty(data), self.numVisible = size(data,1);
            else error('rbmLayer: data is empty'); end;
			%create the initial matrix of weights using zero-mean gaussian w. 0.1 stdev
			%weights are of numHidden x numVisible
			%add 1 for a hidden bias and visible bias unit
			self.numHidden = self.numHidden + 1;
			self.numVisible = self.numVisible + 1;
			randomWeights = randgauss(0, self.sigma, self.numHidden * self.numVisible);
			self.weights = reshape(randomWeights, self.numHidden, self.numVisible);
			%modify data to account for visible bias unit
			data = [data; 0 * ones(1, size(data,2))];
			if ~exist('numEpochs','var'), numEpochs = 100; end; %default number of epochs is 1000
			for epoch = 1:numEpochs
                
                
				randomizedIndexes = randperm(size(data,2)); %we want to get samples in a randomized way
				numBatches = ceil(size(data,2)/self.batchSize); %the number of batches

                
				for batchRun = 1:numBatches
					%get the selection of randomized samples in the batch
					selectionStart = (batchRun-1)*self.batchSize + 1;
					selectionEnd = (batchRun)*self.batchSize;
					selection = randomizedIndexes(selectionStart:selectionEnd);
					batchData = data(:,selection);

					%TODO: use gpu to optimize code GPUstart; batchData = GPUsingle(batchData);
					hid = self.gibbsSampleHgivenV(batchData, false); %(numHidden + 1) x batchSize
					CD0 = hid * batchData'; %(numHidden + 1) x (numVisible + 1)
					[hid, vis] = self.CDk(hid, self.k);%(numHidden + 1) x batchSize, (numVisible + 1) x batchSize
					CDk = hid * vis'; %(numHidden + 1) x (numVisible + 1)

					%we must then normalize the gradient with the size of the batch
					gradient = (CD0 - CDk) / (self.batchSize);
                    %understand that the weights are incremented on data
                    %(CD0)
                    %decremented on reconstruction (CDk)
					%update the weights
					self.weights = self.weights + self.learningRate .* gradient;
                end
                
                
			end
			disp('Finished RBM training');
        end
        
        function [features] = computeActivations(self, patches, varargin)
            %we expect patches to be 
        end
	end
end