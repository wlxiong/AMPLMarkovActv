function TU = cmpTT(run_solver)
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

% run the solver and import data
if run_solver

% export beta to an AMPL .dat file
setPARAM('beta', 0.95)

% run with different travel times
tx1 = 1.0; tx2 = 1.5;
fx1 = run_helper(tx1);
fx2 = run_helper(tx2);

% save flows
save('DATA/FXtt.mat', 'tx1', 'tx2', 'fx1', 'fx2')

else

% load saved flows
load('DATA/FXtt.mat', 'tx1', 'tx2', 'fx1', 'fx2')

end

% plot time use bars
figure; grid off; box off
TU = [getTU(fx1); getTU(fx2)];
barTU(TU', {'Normal condition', 'Congestion situation'});
% export time use into csv
csvwrite('FIGURES/TUtt.csv', TU)
export_fig('FIGURES/TUtt', '-pdf', '-jpg', '-r150')

% also plot fx1 and fx2
figure; grid off; box off
plotFX(fx1)
title('Normal condition')
export_fig(['FIGURES/FXt', num2str(tx1, '%.1f')], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotFX(fx2)
title('Congestion situation')
export_fig(['FIGURES/FXt', num2str(tx2, '%.1f')], '-pdf', '-jpg', '-r150')

end
