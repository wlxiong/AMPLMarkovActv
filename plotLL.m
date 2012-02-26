clear
run DATA/LL.m
run DATA/MLE.m
whos

figure; hold on
plot(t, lf_b1)
plot(b1_, ml, '*')
xlabel('b_1')
ylabel('Likelihood')

figure('Position', [5 5 900 360])
subplot(1,2,2)
pbaspect([1 1 1])
hold on
box on
% The vertices of the mesh lines are the triples (x(j), y(i), Z(i,j)).
% Note that x corresponds to the columns of Z and y corresponds to the rows.
surf(tt, tt, lf_b12', 'FaceAlpha', .9);
plot3(b1_,b2_,ml, '*')
xlabel('b_1')
ylabel('b_2')
zlabel('Likelihood')
view(40,35)

subplot(1,2,1)
pbaspect([1 1 1])
hold on
minc = min(0:-10000:min(lf_b12(:)));
maxc = max(minc:5000:ml);
[cs h] = contourf(tt, tt, lf_b12', [minc:20000:ml, maxc]);
clabel(cs, h, 'FontSize', 14, 'Color', 'r', 'Rotation', 0);
plot(b1_,b2_,'*')
text(b1_,b2_, sprintf('(%.1f,%.1f)', b1_, b2_))
xlabel('b_1')
ylabel('b_2')
