function runUTILS
% plotting utility variables

runAMPL('ChoiceUtils.run')

% load data
clear functions
run 'DATA\actvUtil.m'
% whos

% plot Ua for individual n
n = 1;

figure; grid off; box off
plotUA(squeeze(Ua(n,:,:)))
export_fig('FIGURES/Ua' , '-pdf')
