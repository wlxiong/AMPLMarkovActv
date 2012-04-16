function runMC
% run the Monte Carlo simulation

% TODO activity start time vs activity duration
% TODO out-of-home activity type vs activity duration
% TODO activity start time vs trip distance

clear all

% load data
run DATA/Prob.m
run DATA/EUtil.m
% whos

% load travel time
load DATA/TT.mat travelTime

H = 288;	% number of time slices, and T * H = 1440 minutes
N = 300;	% number of individuals
HOME = 1;	% index of HOME activity

xt = zeros(N,H,'int32');	% travelers' choices
dt = zeros(N,H,'int32');	% travelers' states

for n = 1:N
	if mod(n,50) == 0
		fprintf('%3d...', n)
	end
	xt(n,1) = HOME;		% the dividual stay at home in time slice 1
	t = 1;
	while t <= H
        p = Pr(t,xt(n,t),:);
        p = p(:)./sum(p);      % make sure the probabilites sum to one
		% generate a choice
		dt(n,t) = find( mnrnd(1, p') );
		% state transition
		xt(n, t + travelTime(t, xt(n,t), dt(n,t)) + 1 ) = dt(n,t);
		t = t + travelTime(t, xt(n,t), dt(n,t)) + 1;
	end
end

% save the simulated data
fprintf('\n save the simulation data')
save 'DATA/MC.mat' xt dt EV Pr H N

% export the data to an AMPL .dat file
fprintf('\n export the data as .dat\n')
fid = fopen('DATA/MC.dat', 'W');
exportParam(fid, 'N', N);
exportParam(fid, 'xt', xt(:,1:H), 1, 0);
exportParam(fid, 'dt', dt(:,1:H), 1, 0);
fclose(fid);