function runFLOW
% plotting flow variables

% plot fx for individual n
n = 1;

function run_helper(b)
	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
	clear functions
	run 'DATA\FX.m'
	% whos

	figure; grid off; box off
	plotFX(squeeze(fx(n,:,:)))
	title(['\beta = ', num2str(b,3)])
	export_fig(['FIGURES/FX', num2str(b,3)] , '-pdf')
end

run_helper(.9)
run_helper(.95)

end
