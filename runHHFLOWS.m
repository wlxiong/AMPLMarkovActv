function [ah, fxx1, fxx2] = runHHFLOWS
% plotting flow variables

% plot fx for individual n
n = 2;

function fxx = run_helper(r)
	% export beta to an AMPL .dat file
	fid = fopen('DATA/rho.dat', 'W');
	amplwrite(fid, 'rho', r);
	fclose(fid);

	% start solver
	runAMPL('JointMDPNonlinearEqn.run')

	% load data
    rehash
	clear functions
	run 'DATA\FXX.m'
	fxx = squeeze(fxx(n,:,:));

	% plot fxx
	figure; grid off; box off
	plotFX(fxx)
	title(['\rho = ', num2str(r(3), 3)])
	export_fig(['FIGURES/FXX', num2str(r(3),3)] , '-pdf')
end

% run with rho = 0.0
r1 = [.0 .0 .0];
fxx1 = run_helper(r1);

% run with rho = 0.1
r2 = [.0 .0 .2];
fxx2 = run_helper(r2);

% plot time use bars
figure; grid off; box off
ah = plotAH(fxx1, fxx2);
% export time use into csv
csvwrite('FIGURES/AHhh.csv', [1, 2; ah])
export_fig('FIGURES/TUhh' , '-pdf')

end
