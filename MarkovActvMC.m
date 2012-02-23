% diary MarkovActvMC.log

run DATA/Prob.m
run DATA/EUtil.m

travelTime = [
    0	2	1
    2	0	2
    1	2	0
];

T = 5;		% the equivalent minutes of a time slice
H = 288;	% number of time slices, and T * H = 1440 minutes
M = 3;		% number of activities, 0:home, 1:work, 2:shopping
N = 300;	% number of individuals

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

% save the simulated data
save 'DATA/MC.mat' xt dt

% export the data to an AMPL .dat file
fid = fopen('DATA/MC.dat', 'w');
fprintAmplParamCLSU(fid, 'xt', xt(:,1:H), 1, 0);
fprintAmplParamCLSU(fid, 'dt', dt(:,1:H), 1, 0);