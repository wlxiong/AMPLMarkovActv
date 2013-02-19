function runFLOWS
% plotting flow variables

% plot fx for individual n
n = 1;

function run_helper(b)
	% export beta to an AMPL .dat file
	fid = fopen('DATA/beta.dat', 'W');
	amplwrite(fid, 'beta', b);
	fclose(fid);

	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
    rehash
	clear functions
	run 'DATA\FX.m'
	% whos

	figure; grid off; box off
	plotFX(squeeze(fx(n,:,:)))
	title(['\beta = ', num2str(b,3)])
	export_fig(['FIGURES/FX', num2str(b,3)] , '-pdf')
end

% run with 1x travel time
genTT(1.0)
run_helper(.93)
run_helper(.95)

end
