% diary runMC.log

% TODO activity start time vs activity duration
% TODO out-of-home activity type vs activity duration
% TODO activity start time vs trip distance

clear
run DATA/Prob.m
run DATA/EUtil.m
whos

travelTime = [
    0	2	1
    2	0	2
    1	2	0
];

H = 288;	% number of time slices, and T * H = 1440 minutes
N = 300;	% number of individuals

xt = zeros(N,H,'int8');	% travelers' choices
dt = zeros(N,H,'int8');	% travelers' states

for n = 1:N
	t = 1;
	fprintf('\t%3d', n)
	xt(n,1) = 1;		% we require that the dividual stay at home in time slice 1
	while t <= H
        p = Pr(t,xt(n,t),:);
        p = p(:)./sum(p);      % make sure the probabilites sum to one
		dt(n,t) = find( mnrnd(1, p') );
		xt(n, t + travelTime(xt(n,t), dt(n,t)) + 1 ) = dt(n,t);
		for s = t + 1 : t+travelTime(xt(n,t), dt(n,t))
			xt(n,s) = -1;
			dt(n,s) = -1;
		end
		t = t + travelTime(xt(n,t),dt(n,t)) + 1;
	end
end

% save the simulated data
fprintf('\n save the simulation data')
save 'DATA/MC.mat' xt dt

% export the data to an AMPL .dat file
fprintf('\n export the data as .dat\n')
fid = fopen('DATA/MC.dat', 'W');
fprintAmplParamCLSU(fid, 'xt', xt(:,1:H), 1, 0);
fprintAmplParamCLSU(fid, 'dt', dt(:,1:H), 1, 0);
fclose(fid);