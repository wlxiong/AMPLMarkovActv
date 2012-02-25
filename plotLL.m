run DATA/LL.m

figure; hold on
plot(t, lf_b2);
plot(b2, ml);

figure; hold on
[tt2, tt3] = meshgrid(tt,tt);
mesh(tt2, tt3, lf_b23);
plot3(b2,b3,ml);
