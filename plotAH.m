function ah = plotAH(fx1, fx2, group_names)
% plot activity duration

% average activity duration
T = 5;
M = fx1(1,1);
ah1 = nansum(fx1, 1) / M;
ah2 = nansum(fx2, 1) / M;
ah = [ah1;ah2]';
ah = [ah; 288 - sum(ah, 1)] * T/60;
h = bar(ah, .9, 'EdgeColor', 'k', 'LineWidth', 1, 'LineStyle', '-');

box off
pbaspect([2 1 1])
ylim([0 max(ah(:))*1.1])
ylabel('Average activity duration (hours)')
xlabel('Activities')
set(gca,'XTick',1:size(ah,1))
set(gca,'XTickLabel',{'Home', 'Work', 'Shopping', 'Travel'})
legend(group_names)
legend('boxoff')
