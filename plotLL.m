run DATA/LL.m
whos

figure; hold on
plot(t, lf_b2)
plot(b2, ml, '*')
xlabel('b_2')
ylabel('Likelihood')

figure; hold on
% The vertices of the mesh lines are the triples (x(j), y(i), Z(i,j)).
% Note that x corresponds to the columns of Z and y corresponds to the rows.
mesh(tt, tt, lf_b23)
plot3(b3,b2,ml, '*')

xlabel('b_2')
ylabel('b_3')
zlabel('Likelihood')
view(35,30)

figure; hold on
minc = min(0:-10000:min(lf_b23));
maxc = max(minc:5000:ml);
[cs h] = contourf(tt, tt, lf_b23, [minc:20000:ml, maxc]);
clabel(cs, h, 'FontSize', 14, 'Color', 'r', 'Rotation', 0);
colormap summer
text(b3,b2, sprintf('(%.1f,%.1f)', b3, b2))
plot(b3,b2,'*')
