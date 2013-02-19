function barhTU(y, TU, group_names)
% plot activity duration using stacked bar

% plot the time use bars
barh(y(:), TU, 'stack')
colormap summer

% set axis properties
pbaspect([2 1 1])
xlim([0 24])
x = 0:2:24;
set(gca,'XTick', x)
ylim([min(y(:))-.1*max(y(:)) 1.1*max(y(:))])
ylabel('Interactions coefficient \rho');
xlabel('Average activity duration (hours)')
legend(group_names, 'Location', 'SouthWest');

% set another x-axis at the top
ax1 = gca;
ax2 = axes('Position',get(ax1,'Position'),...
           'YTickLabelMode','manual', ...
           'XAxisLocation','top',...
           'XTick', x, ...
           'XLim',[0 24], ...
           'Color','none');
pbaspect(ax2, [2 1 1])

end
