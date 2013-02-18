function runUTILS
% plotting utility variables

run_solver = true;
if run_solver
    % run the solver
    status = system('ampl ChoiceUtils.run','-echo');
    if status ~= 0
        error('errors in running ChoiceUtils.run')
    end
end

% load data
clear
run 'DATA\actvUtil.m'
% whos

% plot Ua for individual n
n = 1;
plotUA(squeeze(Ua(n,:,:)))
export_fig('FIGURES/Ua' , '-pdf')
