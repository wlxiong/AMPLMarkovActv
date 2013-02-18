function [ah, fx1, fx2] = runTIMEUSE
% plot time use bars

% select individual 1
n = 1;

% run with 1x travel time
genTT(0.5)
runAMPL('MDPNonlinearEqn.run')
% load data
rehash
clear functions
run('DATA\FX.m')
fx1 = squeeze(fx(n,:,:));

% run with 2x travel time
genTT(1.0)
runAMPL('MDPNonlinearEqn.run')
% load data
rehash
clear functions
run('DATA\FX.m')
fx2 = squeeze(fx(n,:,:));

% compare time use
figure; grid off; box off
ah = plotAH(fx1, fx2);
export_fig('FIGURES/TU' , '-pdf')

% also plot fx 
figure; grid off; box off
plotFX(fx1)
figure; grid off; box off
plotFX(fx2)

end
