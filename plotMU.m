% plot the Cauchy curve

% load the parameters
run DATA/Param.m

% HOME-PM
Um(end+1) = Um(1);
b(end+1) = b(1)+1440;
c(end+1) = c(1);

figure
hold on
grid on
box off

tt = 0:30:1440;
lsty = {'-ro', '-r*', '-r^', '-rs'};
for i = 1:length(Um)
	pdf = Um(i)./pi./c(i)./( ( (tt-b(i))/c(i) ).^2 + 1 );
	plot(tt/1440.0, pdf, lsty{i}, 'LineWidth', 1)
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
% export_fig('cauchy_util', '-pdf')
