function runAMPL(runfile)
	% run the solver
	cmd = sprintf('./wine.sh ampl %s', runfile);
	status = system(cmd, '-echo');
	if status ~= 0
	    error(['errors in running: ' cmd])
	end
end
