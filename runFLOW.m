function fx = runFLOW
% calculating flow variables

% run the MDP model
status = system('ampl MarkovActvMDP.run','-echo');
if status ~= 0
	error('errors in running the MDP model')
end

clear all

% load data
run DATA/Prob.m
run DATA/EUtil.m
% whos

% load travel time
load DATA/TT.mat travelTime

H = size(EV, 1);	% number of time slices, and T * H = 1440 minutes
A = size(EV, 2);		% number of activities
N = 3000;	% number of individuals
HOME = 1;	% index of HOME activity

% initialize number of travelers in each state
fx = zeros(H, A);

% all the individuals stay at home in time slice 1
fx(1, HOME) = N;
% calculating f(x)
for t = 1:H
	for a = 1:A
		% make sure the probabilites sum to one
		p = Pr(t,a,:);
		p = p(:)./sum(p);
		for d = 1:A
			% state transition
			if t + travelTime(t, a, d) < H
				fx(t + travelTime(t, a, d) + 1, d) = fx(t + travelTime(t, a, d) + 1, d) + fx(t,a) * p(d);
			end
		end
	end
end

% calculating the average activity duration
ha = nansum(fx, 1) / N;

% visualize EV and Pr
figure
pbaspect([2 1 1])
tt = [1:H]';
plot(tt/H, fx)
ylim([0 N + 500])
set(gca, 'XTick', .0:1.0/6.0:1.0);
datetick('x', 'HH:MM', 'keepticks');

% save the flow variables
fprintf('save the flow variables\n')
save 'DATA/FLOW.mat' fx ha
