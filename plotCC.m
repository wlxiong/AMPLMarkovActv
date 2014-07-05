function plotCC(Um, b, c, filename)
% plot marginal utility function

figure
hold on
grid on
box off

tt = 0:30:1440;
pdf = @(u0, b0, c0) u0./pi./c0./( ( (tt-b0)/c0 ).^2 + 1 );
lsty = {'-ro', '-rv', '-r^'};
for i = 1:length(Um)
  if i == 1
    plot(tt/1440.0, pdf(Um(i), b(i)+1440, c(i)), lsty{i}, 'LineWidth', 0.8)
  end
  plot(tt/1440.0, pdf(Um(i), b(i), c(i)), lsty{i}, 'LineWidth', 0.8)
end

set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
pbaspect([2 1 1])
xlabel('Time of the day')
ylabel('Marginal utility')

axis([.0 1.0 0.0 6])
pbaspect([2 1 1])
legend({'Home-AM', 'Home-PM', 'Work', 'Shopping'}, 'Location', 'NorthWest')
legend('boxoff')
export_fig(['FIGURES/' filename], '-pdf', '-jpg', '-r150')
