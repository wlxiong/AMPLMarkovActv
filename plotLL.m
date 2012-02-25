run DATA/LL.m

figure; hold on
plot(t, lf_b2)
plot(b2, ml, '*')
xlabel('b_2')
ylabel('Likelihood')

figure; hold on
[tt2, tt3] = meshgrid(tt,tt);
mesh(tt2, tt3, lf_b23)
plot3(b3,b2,ml, '*')
xlabel('b_2')
ylabel('b_3')
zlabel('Likelihood')
view(35,30)

figure; hold on
minc = -max(0:10000:-min(lf_b23));
[cs h] = contourf(tt2, tt3, lf_b23, [minc:20000:ml, ml-5000]);
clabel(cs, h, 'FontSize', 14, 'Color', 'r', 'Rotation', 0);
colormap summer
plot3(b3,b2,ml,'*')
