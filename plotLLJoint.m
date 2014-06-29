function plotLL
% plot the log-likelihood function

clear all

% load data
run DATA/jointLL.m
run DATA/jointMLE.m
rho = rho / 10.0;
whos

figure; hold on
pbaspect([2 1 1])
plot(rho, ll_rho3, '-r')
plot(rho_(3), ml, 'r*', 'MarkerSize', 10)
xlabel('\rho_3')
ylabel('Log Likelihood')
export_fig('FIGURES/LLrho3', '-pdf', '-jpg', '-r150')

figure('Position', [5 5 900 360])
subplot(1,2,2)
pbaspect([1 1 1])
hold on
grid on
box on
% The vertices of the mesh lines are the triples (x(j), y(i), Z(i,j)).
% Note that x corresponds to the columns of Z and y corresponds to the rows.
surf(rho, rho, ll_rho13', 'FaceAlpha', .9);
plot3(rho_(1), rho_(3), ml, 'm^', 'MarkerSize', 6, 'MarkerFaceColor', 'm')
text(rho_(1) + 0.05, rho_(3), ml, sprintf('(%.3f,%.3f)', rho_(1), rho_(3)),...
     'BackgroundColor', [.7 .9 .7], 'FontSize', 12)
xlabel('\rho_1')
ylabel('\rho_3')
zlabel('Log Likelihood')
view(20, 60)

subplot(1,2,1)
pbaspect([1 1 1])
hold on
minc = min(0:-10000:min(ll_rho13(:)));
maxc = max(minc:10000:ml);
[cs h] = contourf(rho, rho, ll_rho13', [minc:40000:ml, maxc]);
clabel(cs, h, 'FontSize', 11, 'Color', 'k');
plot(rho_(1), rho_(3), 'm^', 'MarkerSize', 6, 'MarkerFaceColor', 'm')
text(rho_(1) + 0.05, rho_(3), sprintf('(%.3f,%.3f)', rho_(1), rho_(3)),...
     'BackgroundColor', [.7 .9 .7], 'FontSize', 12)
xlabel('\rho_1')
ylabel('\rho_3')
export_fig('FIGURES/LLrho13', '-pdf', '-jpg', '-r150')
