function TU = cmpRHO
% plotting flow variables

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

	% load data
	fxx = readFLOW('DATA\FXX.m', n);

	% plot fxx
	figure; grid off; box off
	plotFX(fxx)
	title(getEQ('\rho', r(3)))
	export_fig(['FIGURES/FXXr', num2str(r(3), '%.1f')] , '-pdf')
end

% export beta to an AMPL .dat file
setPARAM('beta', 0.95)

% run with 1x travel time
genTT(1.0)

% run solver with rho in [0.0 1.0]
rho = 0:.1:1.0;
TU = zeros(length(rho), 4);
for i = 1:length(rho)
	rvec = [.0 .0 rho(i)];
	% run solver
	fxx = run_helper(rvec);
	% get average activity duration
	TU(i,:) = getTU(fxx);
end

% save time use data
save('DATA/TUrr.mat', 'TU', 'rho')
% export time use into csv
csvwrite('FIGURES/TUrr.csv', TU)

% plot time use bars for rho = 0.0 and 0.2
figure; grid off; box off
barTU(TU([1 3],:)', {getEQ('\rho', rho(1)), getEQ('\rho', rho(3))});
export_fig('FIGURES/TUbar' , '-pdf')

% plot time use stacked bars
figure;
barhTU(rho, TU, {'Home', 'Work', 'Shopping', 'Travel'})
export_fig('FIGURES/TUbarh' , '-pdf')

% plot time use 3D bars
figure; box off
bar3TU(rho, TU, {'Home', 'Work', 'Shopping', 'Travel'})
export_fig('FIGURES/TUbar3' , '-pdf')

end
