function plotMU
% plot the Cauchy curve

clear all

% load the true values and estimates
run DATA/MDP.m
run DATA/MLE.m
whos

% HOME-PM
Um0(end+1) = Um0(1);
b0(end+1) = b0(1)+1440;
c0(end+1) = c0(1);
Um_(end+1) = Um_(1);
b_(end+1) = b_(1)+1440;
c_(end+1) = c_(1);

% plot the true and the estimated  marginal utility function
plotCC(Um0, b0, c0, 'cauchy_util_0')
plotCC(Um_, b_, c_, 'cauchy_util_e')
