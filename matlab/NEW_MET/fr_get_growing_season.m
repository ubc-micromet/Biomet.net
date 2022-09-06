function ind_growing_season = fr_get_growing_season(p_measured,tv)
% function ind_growing_season = fr_get_growing_season(p_measured,tv)
% 
% determines index of growing season, 
% works also for any 365 days (e.g. summer to summer instead of jan to dec)
% trace has length of 'tv' and is filled with NaN's for non-growing season
% created 04 july 03, natascha kljun
        
[p_avg,ind_avg,p_std] = runmean(p_measured,5.*48,1);
[yy,mm,dd] = datevec(tv);

ind_p                      = find(p_avg>1);
ind_all                    = NaN*ones(size(tv));
ind_all(ind_avg(ind_p))    = ind_avg(ind_p);
ind_growing                = ta_interp_points(ind_all,5*48);
ind_summer                 = find((6<=mm) & (mm<=8));
ind_summer_all             = NaN*ones(size(tv));
ind_summer_all(ind_summer) = ind_summer;
ind_growing_season         = calc_avg_trace(tv,ind_growing,ind_summer_all);     

return

