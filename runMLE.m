function [LLvec VoTvec Uvec Bvec Cvec] = runMLE
% bootstrap

% set random seed
rand_seed = 31415196;
rng(31415196);
% number of trials in bootstrap
B = 50;
% number of activities
A = 3;
% initialize estimates
Uvec = zeros(B,A);
Bvec = zeros(B,A);
Cvec = zeros(B,A);
LLvec = zeros(B,1);
VOTvec = zeros(B,1);

for j = 1:B
	% run MC simulation
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
save  DATA/MLE LLvec VoTvec Uvec Bvec Cvec
