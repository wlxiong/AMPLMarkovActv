function runFLOW
% plotting flow variables

run_solver = false;
if run_solver
    % run the solver
    status = system('ampl MDPNonlinearEqn.run','-echo');
    if status ~= 0
        error('errors in running MDPNonlinearEqn.run')
    end
end

% load data
clear
run 'DATA\FX.m'
% whos

% plot fx for individual n
n = 1;
plotFX(squeeze(fx(n,:,:)))
export_fig('FIGURES/Fx' , '-pdf')
