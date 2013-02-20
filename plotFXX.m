function plotFXX(prob)

T = 15;
H = 1439;
x = (0:T:H) / 1440.0;
hold on
plot(x', prob(1:(T/5):288, 1), '-ko', 'LineWidth', 1, 'MarkerSize', 6)
plot(x', prob(1:(T/5):288, 2), '-kd', 'LineWidth', 1, 'MarkerSize', 6)
plot(x', prob(1:(T/5):288, 3), '-kv', 'LineWidth', 1, 'MarkerSize', 6)


pbaspect([2 1 1])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
ylim([0 max(prob(:))*1.1])
xlabel('Time of the day (hours)')
ylabel('Activity participation by choice probability')
legend({'Home', 'Work', 'Shopping'},'Location','Southwest')
legend('boxoff')
