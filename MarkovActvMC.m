diary MarkovActvMC.log

run EV/Prob.m
run EV/EUtil.m

travelTime = [
    0	2	1
    2	0	2
    1	2	0
];

T = 20;	% the equivalent minutes of a time slice
H = 72;	% number of time slices, and T * H = 1440 minutes
M = 3;	% number of activities, 0:home, 1:work, 2:shopping
N = 50;	% number of individuals

xt = zeros(N,H);	% travelers' choices
dt = zeros(N,H);	% travelers' states

for n = 1:N
	t = 1;
	xt(n,1) = 1;		% we require that the dividual stay at home in time slice 1
	while t <= H
        p = Pr(t,xt(n,t),:);
        p = p./sum(p);      % make sure the probabilites sum to one
		dt(n,t) = find( mnrnd(1, p(:)') );
		xt(n, t + travelTime(xt(n,t), dt(n,t)) + 1 ) = dt(n,t);
		for s = t + 1 : t+travelTime(xt(n,t), dt(n,t))
			xt(n,s) = -1;
			dt(n,s) = -1;
		end
		t = t + travelTime(xt(n,t),dt(n,t)) + 1;
	end
end
fid = fopen('MarkovActvMC.dat', 'w');
fprintAmplParamCLSU(fid, 'xt', xt, 1);
fprintAmplParamCLSU(fid, 'dt', dt, 1);
