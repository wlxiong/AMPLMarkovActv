function flows = readFLOW(mfile, n)
% load flow data
rehash
clear functions
run(mfile); whos
flows = squeeze(fx(n,:,:));
