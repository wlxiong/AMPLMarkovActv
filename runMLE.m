function [LLvec VOTvec Uvec Bvec Cvec] = runMLE(B,M)
% B: number of trials in bootstrap
% M: number of activities
% bootstrap MLE

% set random seed
rand_seed = 31415196;
rng(rand_seed);
% initialize estimates
Uvec = zeros(B,M);
Bvec = zeros(B,M);
Cvec = zeros(B,M);
LLvec = zeros(B,1);
VOTvec = zeros(B,1);

j = 1;
while j <= B
	% run simulation
	fprintf('\n run simulation (%d/%d)\n', j, B)
	runMC
	% call AMPL to estimate the parameters
	fprintf('\n start MLE (%d/%d)\n', j, B)
	[status,result] = system('wine ampl MarkovActvMLE.run','-echo');
	% import the estimates
	run DATA/MLE.m
	% display the solver message
	disp(solve_message)
	% check the locally optimal solution is obtained
	if solve_return == 0
		LLvec(j) = ml;
		VOTvec(j) = VoT_;
		Uvec(j,:) = Um_;
		Bvec(j,:) = b_;
		Cvec(j,:) = c_;
		j = j + 1;
	end
end

% save the estimates
filename = sprintf('DATA/MLE%dB',B);
save(filename,'LLvec','VOTvec','Uvec','Bvec','Cvec')
