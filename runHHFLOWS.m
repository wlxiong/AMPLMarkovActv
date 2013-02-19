function [ah, fxx0, fxx1] = runHHFLOWS
% plotting flow variables

% plot fx for individual n
n = 2;

function fxx = run_helper(r)
	% export rho to an AMPL .dat file
	setPARAM('rho', r)

	% start solver
	runAMPL('JointMDPNonlinearEqn.run')

	% load data
	fxx = readFLOWS('DATA\FXX.m', n);

	% plot fxx
	figure; grid off; box off
	plotFX(fxx)
	title(['\rho = ', num2str(r(3),  '%.1f')])
	export_fig(['FIGURES/FXXr', num2str(r(3), '%.1f')] , '-pdf')
end

% run with rho = 0.0
r0 = [.0 .0 .0];
fxx0 = run_helper(r0);

% run with rho = 0.2
r1 = [.0 .0 .2];
fxx1 = run_helper(r1);

% plot time use bars
figure; grid off; box off
ah = plotAH(fxx0, fxx1);
% export time use into csv
csvwrite('FIGURES/AHhh.csv', [1, 2; ah])
export_fig('FIGURES/TUhh' , '-pdf')

end
