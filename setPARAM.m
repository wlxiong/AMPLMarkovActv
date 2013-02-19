function setPARAM(pname, pval)
% export parameter to an AMPL .dat file
fid = fopen(['DATA/' pname '.dat'], 'W');
amplwrite(fid, pname, pval);
fclose(fid);
