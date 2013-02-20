function plotFF(fx1, fx2)

T = 15;
H = 1439;
x = (0:T:H) / 1440.0;

hold on
grey = [.5 .5 .5];
plot(x', fx2(1:(T/5):288, 1), '-o', 'Color', grey, 'LineWidth', 1, 'MarkerSize', 6)
plot(x', fx2(1:(T/5):288, 2), '-d', 'Color', grey, 'LineWidth', 1, 'MarkerSize', 6)
plot(x', fx2(1:(T/5):288, 3), '-^', 'Color', grey, 'LineWidth', 1, 'MarkerSize', 6)

h1 = plot(x', fx1(1:(T/5):288, 1), '-ko', 'LineWidth', 1, 'MarkerSize', 6);
h2 = plot(x', fx1(1:(T/5):288, 2), '-kd', 'LineWidth', 1, 'MarkerSize', 6);
h3 = plot(x', fx1(1:(T/5):288, 3), '-k^', 'LineWidth', 1, 'MarkerSize', 6);

pbaspect([2 1 1])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
ylim([0 max(fx1(:))*1.1])
xlabel('Time of the day (hours)')
ylabel('Activity participation by population')

legend([h1 h2 h3], {'Home', 'Work', 'Shopping'},'Location','Southwest')
legend('boxoff')
