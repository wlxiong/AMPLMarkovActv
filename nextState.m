function [x, start_time, end_time] = nextState(t, o, d, h, travelTime)
	if o ~= d && travelTime(t, o, d) ~= h
		disp('wrong duration')
	end
	if o == d
		x = d;
	else
		x = 0;
	end
	start_time = int32(t+1);
	end_time = int32(t+h+1);
end
