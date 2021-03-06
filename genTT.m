function genTT(tx)
% generate travel time data

% show travel time ?
plot_tt = false;

% number of nodes
% 1: home
% 2: work
% 3: shopping
I = 3;
H = 288;

% free travel time
freeTime = [
0	6	4
6	0	6
4	6	0
];
capcity = [
-1		1500	1000
1500	-1		1000
1000	1000	-1
];

% parameter for generating flow
m = [
0		1200	1000
1000	0		1000
1000	 100	0
];
b = [
0		480		1080
1140	0		1110
1140	720		0
];
c = [
-1		240		120
240		-1		240
120		180		-1
];

% traffic flow
t = 0:5:1439;
pdf = @(m_, b_, c_) m_./( ( (t-b_)./c_ ).^2 + 1 );

% BPR function
% bpr = @(x, k, t0) t0 .* ( 1.0 + (x./k).^4);
bpr = @(x, k, t0) t0 * tx;   % constant travel time

if plot_tt
% create a new figure
figure
hold on; grid on; box off
end

travelTime = zeros(length(t), I, I, 'int32');
for i = 1:I
	for j = 1:I
		if freeTime(i,j) == 0
			continue
		end
		ff = pdf(m(i,j), b(i,j), c(i,j));
		tt = bpr(ff, capcity(i,j), freeTime(i,j));
		travelTime(:,i,j) = int8(tt(:));
		if plot_tt
			% plot travel time
			plot(t/1440.0, travelTime(:,i,j), 'LineWidth', 1)
		end
	end
end

if plot_tt
% adjust axis
pbaspect([2 1 1])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');
xlabel('Time of the day')
ylabel('Travel time (\times 5 min)')
axis([0.0 1.0 0.0 max(travelTime(:))*1.1+1])
% export_fig('FIGURES/TT', '-pdf')
end

% save travel time
save 'DATA/TT.mat' travelTime

% export travel time
fid = fopen('DATA/TT.dat', 'W');
amplwrite(fid, 'travelTime', travelTime, 0, 1, 1);
fclose(fid);
