function [weekly_GDD, weekly_tv,growingSeason_GDD,growingSeason_tv] = TLEF_GDD_calc(Tair_daily,tv_daily,GDD_threshold)
weekly_tv = tv_daily(7:7:end);
Tair_diff = Tair_daily - GDD_threshold;
weekly_GDD = fastavg(Tair_diff,7)* 7;
ind = find(weekly_GDD >= 7);
growingSeason_tv = weekly_tv(ind);
growingSeason_GDD = weekly_GDD(ind); 
%growingSeason =  (growingSeason(1):growingSeason(end))*7*48;
%growingSeason_tv = tv_daily(growingSeason);
