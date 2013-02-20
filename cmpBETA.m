function cmpBETA(run_solver)
% plotting flow variables

% plot fx for individual n
n = 1;

function fx = run_helper(b)
	% export beta to an AMPL .dat file
	setPARAM('beta', b)

	% start solver
	runAMPL('MDPNonlinearEqn.run')

	% load data
    fx = readFLOW('DATA\FX.m', n);
end

%% run the solver and import data
if run_solver

% set default values for solver
setDEFAULT()

b1 = .99; b2 = .97;
fx1 = run_helper(b1);
fx2 = run_helper(b2);

% save flows
save('DATA/FXbb.mat', 'b1', 'b2', 'fx1', 'fx2')

else

% load saved flows
load('DATA/FXbb.mat', 'b1', 'b2', 'fx1', 'fx2')

end

% plot flows
figure; grid off; box off
plotFX(fx1)
title(['\beta = ', num2str(b1, '%.2f')])
export_fig(['FIGURES/FXb', num2str(b1, '%.3f')], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotFX(fx2)
title(['\beta = ', num2str(b2, '%.2f')])
export_fig(['FIGURES/FXb', num2str(b2, '%.3f')], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotFF(fx2, fx1)
title(['\beta = ', num2str(b2, '%.2f')])
export_fig(['FIGURES/FXb', num2str(b1, '%.3f'), 'b', num2str(b2, '%.3f')],...
	'-pdf', '-jpg', '-r150')

end
