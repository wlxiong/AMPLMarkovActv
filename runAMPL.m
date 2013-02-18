function runAMPL(runfile)
	% run the solver
	status = system(['ampl ' runfile],'-echo');
	if status ~= 0
	    error(['errors in running ' runfile])
	end
end
