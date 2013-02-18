function plotFX(flows)

figure
hold on
grid off
box off

T = 15;
H = 1439;
x = (0:T:H) / 1440.0;
plot(x', flows(1:(T/5):288,1), '-ko', 'LineWidth', 1, 'MarkerSize', 6)
plot(x', flows(1:(T/5):288,2), '-ks', 'LineWidth', 1, 'MarkerSize', 6)
plot(x', flows(1:(T/5):288,3), '-k*', 'LineWidth', 1, 'MarkerSize', 6)
pbaspect([2 1 1])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
ylim([0 max(flows(:))*1.1])
xlabel('Time of the day (hours)')
ylabel('Activity participation by population')
legend({'Home', 'Work', 'Shopping'},'Location','Southwest')
legend('boxoff')
