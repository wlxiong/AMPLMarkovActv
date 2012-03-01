function plotMU
% plot the Cauchy curve

clear all

% load the parameters
run DATA/MDP.m

% HOME-PM
Um(end+1) = Um(1);
b(end+1) = b(1)+1440;
c(end+1) = c(1);

figure
hold on
grid on
box off

% marginal utility function
tt = 0:30:1440;
pdf = @(u_, b_, c_) u_./pi./c_./( ( (tt-b_)/c_ ).^2 + 1 );

lsty = {'-ro', '-r*', '-r^', '-rs'};
for i = 1:length(Um)
	plot(tt/1440.0, pdf(Um(i), b(i), c(i)), lsty{i}, 'LineWidth', 1)
end

set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
pbaspect([2 1 1])
xlabel('Time of the day')
ylabel('Marginal utility')

axis([.0 1.0 0.0 6])
pbaspect([2 1 1])
legend({'Home-AM', 'Work', 'Shopping', 'Home-PM'},'Location','NorthWest')
legend('boxoff')
export_fig('FIGURES/cauchy_util', '-pdf')
