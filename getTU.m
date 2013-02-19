function TU = getTU(fx)
% get average activity duration

H = 288;
T = 5;
TUa = nansum(fx,1) / fx(1,1);
TT = H - sum(TUa);       % travel time
TU = [TUa, TT] * T / 60;  % convert to hours
