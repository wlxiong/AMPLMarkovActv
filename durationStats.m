function durationStats(xt, M, I)
	% display activity duration stats
	for i = 0:M
		du = zeros(1, I);
		for n = 1:I
			du(n) = sum(xt(n, :) == i);
		end
 		fprintf('  activity %d', i)
		fprintf('  median: %6.2f, mean: %6.2f, std: %6.2f\n', median(du), mean(du), std(du))
	end		
end
