function runFLOWS
% plotting flow variables

% plot fx for individual n
n = 1;

function run_helper(b)
	% export beta to an AMPL .dat file
	setPARAM('beta', b)

	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
    fx = readFLOWS('DATA\FX.m', n);

	figure; grid off; box off
	plotFX(fx)
	title(['\beta = ', num2str(b, '%.2f')])
	export_fig(['FIGURES/FX', num2str(b, '%.2f')] , '-pdf')
end

% run with 1x travel time
genTT(1.0)
run_helper(.93)
run_helper(.95)

end
