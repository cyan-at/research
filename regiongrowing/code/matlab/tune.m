% Tune hyperparameters to search for the best values of k, m, r, a
% hyperparameter space
ks = [10, 20, 30, 40, 50];
rs = [10, 20, 30, 40, 50];
ms = [50, 100, 150, 200, 250];
as = [15000];
infiles = {...
	'pcd0000000024.pcd',...
	'pcd0000000024.pcd',...
	'pcd0000000024.pcd',...
	'pcd0000000024.pcd'...
};
for k in ks
	for r in rs
		for m in ms
			for a in as
				% search hyperparameters for multiple files
				infile = 'data/pcd0000000024.pcd';
				outdir = './data/';
				k = num2str(30);
				r = num2str(20);
				m = num2str(100);
				a = num2str(15000);
				resultFile = sprintf()
				cmd = sprintf('/home/charlie/Desktop/research/regiongrowing/code/pclcode/segment.out -i %s -o %s -k %s -r %s -m %s -a %s > ', infile, outdir, k, r, m, a);

			end
		end
	end
end