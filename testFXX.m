% clear functions
% run('DATA\FX.m')
% figure; grid off; box off
% plotFX(squeeze(fx(1,:,:)))

clear functions
run('DATA\FXX.m')
figure; grid off; box off
fx1 = squeeze(fx(1,:,:));
plotFX(fx1)

clear functions
run('DATA\FXX.m')
figure; grid off; box off
fx2 = squeeze(fx(2,:,:));
plotFX(fx2)

figure; grid off; box off
ah = plotAH(fx1, fx2, {'HH member 1', 'HH member 2'});
