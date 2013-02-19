function testHHFLOWS(r)
	% export beta to an AMPL .dat file
	fid = fopen('DATA/rho.dat', 'W');
	amplwrite(fid, 'rho', r);
	fclose(fid);

	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
	clear functions
	run 'DATA\FXX.m'
	% whos
    
    n = 2;
	figure; grid off; box off
	plotFX(squeeze(fxx(n,:,:)))
	title(['\rho = ', num2str(r(3),3)])
	export_fig(['FIGURES/FXX', num2str(r(3),3)] , '-pdf')
end
