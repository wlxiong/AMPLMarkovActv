function TU = cmpALPHA(run_solver)
% plot time use bars

% select individual 1
n = 1;

function fx = run_helper(alpha)
	% run with alpha as VoT
	setPARAM('VoT', alpha)

	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
	fx = readFLOW('DATA\FX.m', n);
end

% run the solver and import data
if run_solver

% set default values for solver
setDEFAULT()

% start solver
a1 = 60; a2 = 120;
fx1 = run_helper(a1);
fx2 = run_helper(a2);

% save flows
save('DATA/FXaa.mat', 'a1', 'a2', 'fx1', 'fx2')

else

% load saved flows
load('DATA/FXaa.mat', 'a1', 'a2', 'fx1', 'fx2')

end

% plot time use bars
figure; grid off; box off
TU = [getTU(fx1); getTU(fx2)];
barTU(TU', {['\alpha = ', num2str(a1)], ['\alpha = ', num2str(a2)]});
% export time use into csv
csvwrite('FIGURES/TUaa.csv', TU)
export_fig('FIGURES/TUaa', '-pdf', '-jpg', '-r150')

% also plot fx1 and fx2
figure; grid off; box off
plotFX(fx1)
title(['\alpha = ', num2str(a1)])
export_fig(['FIGURES/FXa', num2str(a1, '%.0f')], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotFX(fx2)
title(['\alpha = ', num2str(a2)])
export_fig(['FIGURES/FXa', num2str(a2, '%.0f')], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotFF(fx2, fx1)
title(['\alpha = ', num2str(a2)])
export_fig(['FIGURES/FXa', num2str(a1, '%.1f'), 'a', num2str(a2, '%.1f')],...
	'-pdf', '-jpg', '-r150')

end
