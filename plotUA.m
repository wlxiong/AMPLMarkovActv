function plotUA(utils)

figure
hold on
grid off
box off

T = 15;
H = 1439;
x = (0:T:H) / 1440.0;
plot(x', utils(1, 1:(T/5):288), '-ko', 'LineWidth', 1, 'MarkerSize', 6)
plot(x', utils(2, 1:(T/5):288), '-ks', 'LineWidth', 1, 'MarkerSize', 6)
plot(x', utils(3, 1:(T/5):288), '-k*', 'LineWidth', 1, 'MarkerSize', 6)
pbaspect([2 1 1])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
ylim([0 max(utils(:))*1.1])
xlabel('Time of the day (hours)')
ylabel('Marginal activity utility')
legend({'Home', 'Work', 'Shopping'},'Location','Southwest')
legend('boxoff')
