function runUTILS
% plotting utility variables

% plot Ua for individual n
n = 1;

runAMPL('ChoiceUtils.run')

% load data
clear functions
run 'DATA\actvUtil.m'
% whos

figure; grid off; box off
plotUA(squeeze(Ua(n,:,:)))
export_fig('FIGURES/UA' , '-pdf')
