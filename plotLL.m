function plotLL
% plot the log-likelihood function

clear all

% load data
run DATA/LL.m
run DATA/MLE.m
whos

figure; hold on
pbaspect([2 1 1])
plot(tt, lf_b2, '-r')
plot(b_(2), ml, 'r*', 'MarkerSize', 10)
xlabel('b_2')
ylabel('Log Likelihood')
export_fig('FIGURES/LLb2', '-pdf')

figure('Position', [5 5 900 360])
subplot(1,2,2)
pbaspect([1 1 1])
hold on
box on
% The vertices of the mesh lines are the triples (x(j), y(i), Z(i,j)).
% Note that x corresponds to the columns of Z and y corresponds to the rows.
surf(tt, tt, lf_b23', 'FaceAlpha', .9);
plot3(b_(2),b_(3),ml, 'm*', 'MarkerSize', 10)
xlabel('b_2')
ylabel('b_3')
zlabel('Log Likelihood')
view(40,45)

subplot(1,2,1)
pbaspect([1 1 1])
hold on
minc = min(0:-10000:min(lf_b23(:)));
maxc = max(minc:10000:ml);
[cs h] = contourf(tt, tt, lf_b23', [minc:40000:ml, maxc]);
clabel(cs, h, 'FontSize', 12, 'Color', 'k');
plot(b_(2),b_(3),'m*', 'MarkerSize', 8)
text(b_(2),b_(3), sprintf('(%.1f,%.1f)', b_(2), b_(3)))
xlabel('b_2')
ylabel('b_3')
export_fig('FIGURES/LLb23', '-pdf')