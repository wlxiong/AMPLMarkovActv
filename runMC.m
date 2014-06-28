function runMC(I)
% run the Monte Carlo simulation
%   I: number of individuals
%
% TODO activity start time vs activity duration
% TODO out-of-home activity type vs activity duration
% TODO activity start time vs trip distance

M = 3;		% number of activities
H = 288;	% number of time slices, and T * H = 1440 minutes
DH = 36;	% the longest duration for a decision
HOME = 1;	% index of HOME activity
n1 = 1;		% person 1

% load data
Pr = zeros(2, H, M, M, DH);
EV = zeros(2, H, M);
run DATA/choiceProb.m
run DATA/EUtil.m
% load travel time
load DATA/TT.mat travelTime

function [x, h] = choice(p)
	dim = size(p);
	% make sure the probabilites sum to one
    p = p(:)./sum(p(:));
	% generate a choice
	d = find(mnrnd(1, p'));
	[x, h] = ind2sub(dim, d);
end

function [xt, dx, dh] = simulate(p)
	% p: household member, 1 or 2
	xt = zeros(I,H,'int32');	% travelers' states
	dx = zeros(I,H,'int32');	% travelers' activity choices
	dh = zeros(I,H,'int32');	% travelers' activity duration choices
	for n = 1:I
		if mod(n,100) == 0
			fprintf('%3d...', n)
		end
		xt(n,1) = HOME;		% the individual stay at home in time slice 1
		t = 1;
		while t <= H
			[x, h] = choice(squeeze(Pr(p, t, xt(n,t), :, :)));
			dx(n,t) = x;
			dh(n,t) = h;
			[y, start_time, end_time] = nextState(t, xt(n,t), dx(n,t), dh(n,t), travelTime);
			xt(n, start_time:end_time-1) = y;
			xt(n, end_time) = dx(n,t);
			t = end_time;
		end
	end
	fprintf('\n')
end

[xt1, dx1, dh1] = simulate(1);
[xt2, dx2, dh2] = simulate(2);

% display activity duration stats
fprintf('\n> person 1\n')
durationStats(xt1, M, I)
fprintf('\n> person 2\n')
durationStats(xt2, M, I)

% save the simulated data
fprintf('\n save the simulation data')
save 'DATA/MC.mat' dx* dh* xt* EV Pr H I

% export the data to an AMPL .dat file
fprintf('\n export the data as .dat\n')
fid = fopen('DATA/MC.dat', 'W');
amplwrite(fid, 'n1', n1);
amplwrite(fid, 'I', I);
amplwrite(fid, 'xt1', xt1(:,1:H), 1, 0);
amplwrite(fid, 'xt2', xt2(:,1:H), 1, 0);
amplwrite(fid, 'dx1', dx1(:,1:H), 1, 0);
amplwrite(fid, 'dx2', dx2(:,1:H), 1, 0);
amplwrite(fid, 'dh',  dh1(:,1:H), 1, 0);
fclose(fid);
end
