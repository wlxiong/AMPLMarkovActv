% clear functions
% run('DATA\FX.m')
% figure; grid off; box off
% plotFX(squeeze(fx(1,:,:)))

clear functions
run('DATA\FXX00.m')
figure; grid off; box off
fx1 = squeeze(fxx(1,:,:));
plotFX(fx1)

clear functions
run('DATA\FXX02.m')
figure; grid off; box off
fx2 = squeeze(fxx(1,:,:));
plotFX(fx2)

figure; grid off; box off
ah = plotAH(fx1, fx2);
