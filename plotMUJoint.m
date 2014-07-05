function plotMUJoint
% plot the Cauchy curve

clear all

% load the true values and estimates
run DATA/jointMDP.m
run DATA/jointMLE.m
whos

% plot the true and the estimated  marginal utility function
plotCCJoint(Um0, b0, c0, 'joint_cauchy_util_0')
plotCCJoint(Um_, b_, c_, 'joint_cauchy_util_e')
