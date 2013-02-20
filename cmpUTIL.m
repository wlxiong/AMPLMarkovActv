function cmpUTIL(run_solver)
% plotting utility variables

% run the solver and import data
if run_solver

runAMPL('ExportActvUtils.run')

% import and save data
clear functions
run 'DATA/actvUtil.m'
save('DATA/UA.mat', 'Ua')

else

% load the saved data
load('DATA/UA.mat', 'Ua')

end

% plot Ua for individual n
for n = 1:2
	figure; grid off; box off
	plotUA(squeeze(Ua(n,:,:)))
	export_fig(['FIGURES/UA' num2str(n)], '-pdf', '-jpg', '-r150')
end
