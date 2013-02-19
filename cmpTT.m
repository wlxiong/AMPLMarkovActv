function [TU, fx0, fx1] = cmpTT
% plot time use bars

% select individual 1
n = 1;

function fx = run_helper(tx)
	% run with tx travel time
	genTT(tx)

	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
	fx = readFLOW('DATA\FX.m', n);
end

% export beta to an AMPL .dat file
setPARAM('beta', 0.95)

% run with 1x travel time
tx0 = 1.0;
fx0 = run_helper(1.0);

% run with 1.5x travel time
tx1 = 1.5;
fx1 = run_helper(1.5);

% plot time use bars
figure; grid off; box off
ah = plotAH(fx0, fx1, {'Normal condition', 'Congestion situation'});
% export time use into csv
csvwrite('FIGURES/TUtt.csv', [tx0, tx1; ah])
export_fig('FIGURES/TUtt' , '-pdf')

% also plot fx0 and fx1
figure; grid off; box off
plotFX(fx0)
export_fig(['FIGURES/FXt', num2str(tx0, '%.1f')] , '-pdf')
figure; grid off; box off
plotFX(fx1)
export_fig(['FIGURES/FXt', num2str(tx1, '%.1f')] , '-pdf')

end
