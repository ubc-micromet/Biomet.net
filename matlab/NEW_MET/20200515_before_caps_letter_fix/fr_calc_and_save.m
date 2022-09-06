function st = fr_calc_and_save(siteID,year,month,day,LocalTimeFlag,LocalPth)
% st = fr_calc_and_save(siteID,year,month,day,LocalTimeFlag,LocalPth)

if ~exist('LocalPth')
    LocalPth = [];
end

for i=day
    try,
    	stats = fr_calc_one_day_stats(siteID,year,month,i,LocalTimeFlag);
        st = fr_save_hhour(siteID,stats,LocalPth);
    end
end	
