function barTU(TU, group_names)
% plot activity duration

% plot bars
bar(TU, .9, 'EdgeColor', 'k', 'LineWidth', 1, 'LineStyle', '-');
colormap(gray)
% label bars
x = [ (1:size(TU,1))-.15; (1:size(TU,1))+.15]';
text(x(:), TU(:), strcat(num2str(TU(:),'%.1f'),'h'),...
	'FontSize',11,'horiz','center','vert','bottom')

% set axis properties
box off
pbaspect([2 1 1])
ylim([0 max(TU(:))*1.1])
ylabel('Average activity duration (hours)')
xlabel('Activities')
set(gca,'YTick',0:2:max(TU(:))*1.1)
set(gca,'XTick',1:size(TU,1))
set(gca,'XTickLabel',{'Home', 'Work', 'Shopping', 'Travel'})
legend(group_names)
legend('boxoff')
