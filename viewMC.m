clear
load 'DATA/MC.mat' EV xt H N
whos

tt = [1:H]';

% visualize EV and Pr
figure
plot(tt/H, EV(1:H,:))
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');

% visualize xt
figure
hold on
for n = 1:N
	xx = xt(n,1:H);
	ii = [xx(:) ~= 0];
	xx = xx(ii);
	plot(tt(ii)/H, xx)
end
ylim([.5 3.5])
set(gca,'YTick',[1 2 3])
set(gca,'YTickLabel','Home|Work|Shopping')
pbaspect([2 1 1])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
xlabel('Time of the day')
export_fig('FIGURES/xt', '-pdf')

% caculate number of trips
num_trips = zeros(1,N);
for n = 1:N
	xx = xt(n,1:H);
	edges = diff([0;xx(:) == 0]);
	num_trips(n) = sum(edges > 0);
end
% draw histgram of trip numbers
figure
hist(num_trips)
