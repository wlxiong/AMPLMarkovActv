function plotCCJoint(Um, b, c, filename)
% plot marginal utility function

figure('Position', [5, 5, 640, 480])
hold on
grid on

tt = 0:30:1440;
pdf = @(u0, b0, c0) u0./pi./c0./( ( (tt-b0)/c0 ).^2 + 1 );
lsty = {{'-ro', '-rv', '-r^'}, {'--bo', '--bv', '--b^'}};
for j = 1:2
  for i = 1:length(Um(j,:))
    if i == 1
      plot(tt/1440.0, pdf(Um(j,i), b(j,i)+1440, c(j,i)), lsty{j}{i}, 'LineWidth', 0.8)
    end
    plot(tt/1440.0, pdf(Um(j,i), b(j,i), c(j,i)), lsty{j}{i}, 'LineWidth', 0.8)
  end
end

set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
pbaspect([2 1 1])
xlabel('Time of the day')
ylabel('Marginal utility')

axis([.0 1.0 0.0 6])
pbaspect([2 1 1])
legend({'Home-AM 1', 'Home-PM 1', 'Work 1', 'Shopping 1',...
        'Home-AM 2', 'Home-PM 2', 'Work 2', 'Shopping 2'},...
        'Location', 'SouthEastOutside')
% legend('boxoff')
export_fig(['FIGURES/' filename], '-pdf', '-jpg', '-r150')
