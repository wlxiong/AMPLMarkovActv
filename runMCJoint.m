function runMC(I)
% run the Monte Carlo simulation
%   I: number of households
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
Pj = zeros(H, M, M, M, M, DH);
EW = zeros(H, M, M);
run DATA/jointChoiceProb.m
run DATA/jointEUtil.m
% load travel time
load DATA/TT.mat travelTime

function [x1, x2, h] = choice(p)
	dim = size(p);
	% make sure the probabilites sum to one
    p = p(:)./sum(p(:));
	% generate a choice
	d = find(mnrnd(1, p'));
	[x1, x2, h] = ind2sub(dim, d);
end

xt1 = zeros(I,H,'int32');	% travelers' states
xt2 = zeros(I,H,'int32');	% travelers' states
dx1 = zeros(I,H,'int32');	% travelers' activity choices
dx2 = zeros(I,H,'int32');	% travelers' activity choices
dh = zeros(I,H,'int32');	% travelers' activity duration choices

for n = 1:I
	if mod(n,100) == 0
		fprintf('%3d...', n)
	end
	xt1(n,1) = HOME;		% the individual stay at home in time slice 1
	xt2(n,1) = HOME;		% the individual stay at home in time slice 1
	t = 1;
	while t <= H
		[x1, x2, h] = choice(squeeze(Pj(t, xt1(n,t), xt2(n,t), :, :, :)));
		dx1(n,t) = x1;
		dx2(n,t) = x2;
		dh(n,t) = h;
		[x1, start_time1, end_time1] = nextState(t, xt1(n,t), dx1(n,t), dh(n,t), travelTime);
		[x2, start_time2, end_time2] = nextState(t, xt2(n,t), dx2(n,t), dh(n,t), travelTime);
		xt1(n, start_time1:end_time1-1) = x1;
		xt2(n, start_time2:end_time2-1) = x2;
		xt1(n, end_time1) = dx1(n,t);
		xt2(n, end_time2) = dx2(n,t);
		assert(end_time1 == end_time2);
		t = min(end_time1, end_time2);
	end
end
fprintf('\n')
% display activity duration stats
fprintf('\n> person 1\n')
durationStats(xt1, M, I)
fprintf('\n> person 2\n')
durationStats(xt2, M, I)

% save the simulated data
fprintf('\n save the simulation data')
save 'DATA/MC.mat' dx* dh xt* EW Pj H I

% export the data to an AMPL .dat file
fprintf('\n export the data as .dat\n')
fid = fopen('DATA/JointMC.dat', 'W');
amplwrite(fid, 'n1', n1);
amplwrite(fid, 'I', I);
amplwrite(fid, 'xt1', xt1(:,1:H), 1, 0);
amplwrite(fid, 'xt2', xt2(:,1:H), 1, 0);
amplwrite(fid, 'dx1', dx1(:,1:H), 1, 0);
amplwrite(fid, 'dx2', dx2(:,1:H), 1, 0);
amplwrite(fid, 'dh', dh(:,1:H), 1, 0);
fclose(fid);
end
