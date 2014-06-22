function runMC
% run the Monte Carlo simulation

% TODO activity start time vs activity duration
% TODO out-of-home activity type vs activity duration
% TODO activity start time vs trip distance

clear all

% load data
run DATA/choiceProb.m
run DATA/EUtil.m
% whos

% load travel time
load DATA/TT.mat travelTime

H = 288;	% number of time slices, and T * H = 1440 minutes
I = 300;	% number of individuals
HOME = 1;	% index of HOME activity

dx = zeros(N,H,'int32');	% travelers' activity choices
dh = zeros(N,H,'int32');	% travelers' activity duration choices
xt = zeros(N,H,'int32');	% travelers' states
n1 = 1;						% person 1

for n = 1:I
	if mod(n,50) == 0
		fprintf('%3d...', n)
	end
	xt(n,1) = HOME;		% the individual stay at home in time slice 1
	t = 1;
	while t <= H
		% [l, t, xt(n,t)]
        p = squeeze(Pr(n1, t, xt(n,t), :, :));
		num_actv = size(p, 1);
        p = p(:)./sum(p(:));      % make sure the probabilites sum to one
		% generate a choice
		d = find(mnrnd(1, p'));
		dx(n,t) = mod(d - 1, num_actv) + 1;
		dh(n,t) = idivide(int32(d - 1), num_actv) + 1;
		% dh(n,t)
		% dx(n,t)
		% state transition
		% size(xt)
		% size(travelTime)
		% size(dh)
		start_time = int32(t + travelTime(t, xt(n,t), dx(n,t)) + 1);
		end_time = int32(start_time + dh(n,t));
		% [start_time, end_time]
		xt(n, start_time:end_time) = dx(n,t);
		t = end_time;
	end
end

% save the simulated data
fprintf('\n save the simulation data')
save 'DATA/MC.mat' dx dh xt EV Pr H N

% export the data to an AMPL .dat file
fprintf('\n export the data as .dat\n')
fid = fopen('DATA/MC.dat', 'W');
amplwrite(fid, 'n1', n1);
amplwrite(fid, 'I', I);
amplwrite(fid, 'xt', xt(:,1:H), 1, 0);
amplwrite(fid, 'dx', dx(:,1:H), 1, 0);
amplwrite(fid, 'dh', dh(:,1:H), 1, 0);
fclose(fid);