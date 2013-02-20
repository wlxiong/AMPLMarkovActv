function TU = cmpRHO(rho, run_solver)
% plotting flow variables with rho in a range, eg. 0:.1:.2 or 0:-.1:-.2

% plot fx for individual n
n = 2;

function str = getEQ(name, val)
    % get the string for an equality 
    str = [name, ' = ', num2str(val,  '%.1f')];
end

function fxx = run_helper(r)
	% export rho to an AMPL .dat file
	setPARAM('rho', r)

	% start solver
	runAMPL('JointMDPNonlinearEqn.run')

	% import and save data
	fxx = readFLOW('DATA\FXX.m', n);
	save(['DATA/FXX', num2str(r(3), '%.1f'), '.mat'], 'fxx')
end

%% run the solver and import data
if run_solver

% set default values for solver
setDEFAULT()

% run solver with rho
TU = zeros(length(rho), 4);
for i = 1:length(rho)
	rvec = [.0 .0 rho(i)];
	% run solver
	fxx = run_helper(rvec);
	% get average activity duration
	TU(i,:) = getTU(fxx);
end

% save time use data
save(['DATA/TUrr', num2str(rho(end), '%.1f'), '.mat'], 'TU', 'rho')
% export time use into csv
csvwrite(['DATA/TUrr', num2str(rho(end), '%.1f'), '.csv'], TU)

else

% load time use data
load(['DATA/TUrr', num2str(rho(end), '%.1f'), '.mat'], 'TU', 'rho')

end

% plot fxx for each value of rho
for i = 1:length(rho)
	% load saved fxx values
	clear fxx
	load(['DATA/FXX', num2str(rho(i), '%.1f'), '.mat'], 'fxx')
    % plot activity participation probability
	figure; grid off; box off
	plotFXX(fxx./fxx(1,1))
	title(getEQ('\rho', rho(i)))
	export_fig(['FIGURES/FXXr', num2str(rho(i), '%.1f')], '-pdf', '-jpg', '-r150')
end

% plot time use bars for rho(1) and rho(3)
figure; grid off; box off
barTU(TU([1 3],:)', {getEQ('\rho', rho(1)), getEQ('\rho', rho(3))});
export_fig(['FIGURES/TUr', num2str(rho(1), '%.1f'), 'r', num2str(rho(3), '%.1f')],...
	'-pdf',  '-jpg', '-r150')

% plot time use stacked bars
figure;
barhTU(rho, TU, {'Home', 'Work', 'Shopping', 'Travel'})
export_fig('FIGURES/TUbarh', '-pdf', '-jpg', '-r150')

% plot time use 3D bars
figure; box off
bar3TU(rho, TU, {'Home', 'Work', 'Shopping', 'Travel'})
export_fig('FIGURES/TUbar3', '-pdf', '-jpg', '-r150')

end
