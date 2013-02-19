function cmpUTIL
% plotting utility variables

runAMPL('ExportActvUtils.run')

% load data
clear functions
run 'DATA\actvUtil.m'
% whos


% plot Ua for individual n
for n = 1:2
	figure; grid off; box off
	plotUA(squeeze(Ua(n,:,:)))
	export_fig(['FIGURES/UA' num2str(n)] , '-pdf')
end
