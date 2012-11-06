% Tune hyperparameters to search for the best values of k, m, r, a
% hyperparameter space
ks = [10, 20, 30, 40, 50];
rs = [10, 20, 30, 40, 50];
ms = [50, 100, 150, 200, 250];
as = [15000];
infiles = {...
	'pcd0000000024.pcd'
};
outdir = './data/';

count = 0;
for k in ks
	for r in rs
		for m in ms
			for a in as
				for infile in infiles
					% search hyperparameters for multiple files
					resultsFile = sprintf('./data/%s.txt', num2str(count));
					cmd = sprintf('/home/charlie/Desktop/research/regiongrowing/code/pclcode/segment.out -i %s -o %s -k %s -r %s -m %s -a %s > %s', ...
						cell2mat(infile), outdir, num2str(k), num2str(r), num2str(m), num2str(a), resultsFile);
					system(cmd);

					% clean up
					system('rm ./data/*.pcd');
					count = count + 1;
				end
			end
		end
	end
end

