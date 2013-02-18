function runFLOW
% plotting flow variables

% run with 1x travel time
genTT(1.0)
runAMPL('MDPNonlinearEqn.run')

% load data
clear functions
run 'DATA\FX.m'
% whos

% plot fx for individual n
n = 1;

figure; grid off; box off
plotFX(squeeze(fx(n,:,:)))
export_fig('FIGURES/Fx' , '-pdf')
