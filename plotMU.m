function plotMU
% plot the Cauchy curve

clear all

% load the true values and estimates
run DATA/MDP.m
run DATA/MLE.m
whos

% plot the true and the estimated  marginal utility function
plotCC(Um0(n1,:), b0(n1,:), c0(n1,:), 'cauchy_util_0')
plotCC(Um_(n1,:), b_(n1,:), c_(n1,:), 'cauchy_util_e')
