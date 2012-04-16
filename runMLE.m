function [LLvec VOTvec Uvec Bvec Cvec] = runMLE(B,A)
% B: number of trials in bootstrap
% A: number of activities
% bootstrap MLE

% set random seed
rand_seed = 31415196;
rng(31415196);
% initialize estimates
Uvec = zeros(B,A);
Bvec = zeros(B,A);
Cvec = zeros(B,A);
LLvec = zeros(B,1);
VOTvec = zeros(B,1);

for j = 1:B
	% run simulation
	fprintf('\n run simulation (%d/%d)\n', j, B)
	runMC
	% call AMPL to estimate the parameters
	fprintf('\n start MLE (%d/%d)\n', j, B)
	[status,result] = system('wine ampl MarkovActvMLE.run','-echo')
	% import the estimates
	run DATA/MLE.m
	LLvec(j) = ml;
	VOTvec(j) = VoT_;
	Uvec(j,:) = Um_;
	Bvec(j,:) = b_;
	Cvec(j,:) = c_;
end

% save the estimates
save  DATA/MLE LLvec VOTvec Uvec Bvec Cvec
