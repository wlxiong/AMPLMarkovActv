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


T = 15;
H = 1439;
x = (0:T:H) / 1440.0;

% plot Ua for individual n
for n = 1:2
	figure; grid off; box off
	plotUA(x, squeeze(Ua(n,:,1:(T/5):288)))
	export_fig(['FIGURES/UA' num2str(n)], '-pdf', '-jpg', '-r150')
end

Ua1 = squeeze(Ua(1,:,1:(T/5):288));
Ua2 = squeeze(Ua(2,:,1:(T/5):288));

figure; grid off; box off
plotUA(x, Ua1)
plot(x, max(Ua1(1:3,:), [], 1), '-k', 'LineWidth', 2)
export_fig(['FIGURES/UAsamp' num2str(n)], '-pdf', '-jpg', '-r150')

figure; grid off; box off
plotUA(x, Ua1)
grey = [.5 .5 .5];
plot(x, Ua2(3, :), '-^', 'Color', grey, 'LineWidth', 1, 'MarkerSize', 6)
legend({'Home', 'Work', 'Shopping 1', 'Shopping 2'},...
	'Location', 'Southwest', 'FontSize', 11)
legend('boxoff')
export_fig('FIGURES/UA12', '-pdf', '-jpg', '-r150')
