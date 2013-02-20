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

% set default values for solver
setDEFAULT()

% run with different travel times
tt1 = 1.0; tt2 = 2.0;
fx1 = run_helper(tt1);
fx2 = run_helper(tt2);

% save flows
save('DATA/FXtt.mat', 'tt1', 'tt2', 'fx1', 'fx2')

else

% load saved flows
load('DATA/FXtt.mat', 'tt1', 'tt2', 'fx1', 'fx2')

end

% plot time use bars
figure; grid off; box off
TU = [getTU(fx1); getTU(fx2)];
barTU(TU', {'Normal traffic condition', 'Traffic congestion condition'});
% export time use into csv
csvwrite('FIGURES/TUtt.csv', TU)
export_fig('FIGURES/TUtt', '-pdf', '-jpg', '-r150')

% also plot fx1 and fx2
figure; grid off; box off
plotFX(fx1)
title('Normal traffic condition')
export_fig(['FIGURES/FXt', num2str(tt1, '%.1f')], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotFX(fx2)
title('Traffic congestion condition')
export_fig(['FIGURES/FXt', num2str(tt2, '%.1f')], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotFF(fx2, fx1)
title('Traffic congestion condition')
export_fig(['FIGURES/FXt', num2str(tt1, '%.1f'), 't', num2str(tt2, '%.1f')],...
	'-pdf', '-jpg', '-r150')

end
