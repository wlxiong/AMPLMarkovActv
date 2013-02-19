function bar3TU(x, TU, group_names)
% plot activity duration using 3d bars


% plot the time use bars
bar3(x(:), TU)
view(125,30)
colormap summer

% set axis properties
set(gca, 'ZTick', 0:2:max(TU(:)));
set(gca, 'XTick', 1:size(TU,2))
set(gca, 'XTickLabel', group_names);
zlabel('Average activity duration (hours)')
ylabel('Interactions coefficient \rho', 'rot', -20);
ylim([min(x(:))-.1*max(x(:)) 1.1*max(x(:))])
