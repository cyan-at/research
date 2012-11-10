% Tune hyperparameters to search for the best values of k, m, r, a
% hyperparameter space
clc;
ks = 10:5:90;
rs = 10:5:60;
ms = [50, 100, 150, 200, 250];
as = [15000, 20000];
infiles = {'/home/charlie/Desktop/research/regiongrowing/code/pclcode/data/source/pcd0000000024.pcd'};
outdir = '/home/charlie/Desktop/research/regiongrowing/code/pclcode/data/';
count = 0;
for k = ks
	for r = rs
		for m = ms
			for a = as
				for infile = infiles
                    disp(count);
					% search hyperparameters for multiple files
					resultsFile = sprintf('/home/charlie/Desktop/research/regiongrowing/code/pclcode/data/%s.txt', num2str(count));
					cmd = sprintf('/home/charlie/Desktop/research/regiongrowing/code/pclcode/segment.out -i %s -o %s -k %s -r %s -m %s -a %s > %s', ...
						cell2mat(infile), outdir, num2str(k), num2str(r), num2str(m), num2str(a), resultsFile);
					system(cmd);

					% clean up
					system('rm /home/charlie/Desktop/research/regiongrowing/code/pclcode/data/*.pcd');    
					count = count + 1;
				end
			end
		end
	end
end
% at this point we should have a bunch of txt files
% analyze results

