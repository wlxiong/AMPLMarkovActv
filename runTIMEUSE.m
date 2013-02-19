function [ah, fx1, fx2] = runTIMEUSE
% plot time use bars

% select individual 1
n = 1;

function fx = run_helper(tx)
	% run with tx travel time
	genTT(tx)

	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
	rehash
	clear functions
	run('DATA\FX.m')
	fx = squeeze(fx(n,:,:));
end

% export beta to an AMPL .dat file
fid = fopen('DATA/beta.dat', 'W');
amplwrite(fid, 'beta', 0.95);
fclose(fid);

% run with 1.5x travel time
fx2 = run_helper(1.5);

% run with 1x travel time
fx1 = run_helper(1.0);

% plot time use bars
figure; grid off; box off
ah = plotAH(fx1, fx2);
% export time use into csv
csvwrite('FIGURES/AH.csv', [1, 2; ah])
export_fig('FIGURES/TU' , '-pdf')

% also plot fx1 and fx2
figure; grid off; box off
plotFX(fx1)
export_fig('FIGURES/FX1x' , '-pdf')
figure; grid off; box off
plotFX(fx2)
export_fig('FIGURES/FX2x' , '-pdf')

end
