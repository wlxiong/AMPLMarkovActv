function plotUA(x, utils)

hold on
plot(x, utils(1, :), '-ko', 'LineWidth', 1, 'MarkerSize', 6)
plot(x, utils(2, :), '-kd', 'LineWidth', 1, 'MarkerSize', 6)
plot(x, utils(3, :), '-k^', 'LineWidth', 1, 'MarkerSize', 6)

pbaspect([2 1 1])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
ylim([0 max(utils(:))*1.1])
xlabel('Time of the day (hours)')
ylabel('Marginal activity utility')
legend({'Home', 'Work', 'Shopping'},'Location','Southwest')
legend('boxoff')
