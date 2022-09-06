function fr_calc_and_save_rmy(SiteId,year,month,day)

% if no arguments do calc for yesterday
if nargin == 0
    dv_now = datevec(now);
    SiteId = fr_current_siteid;
    year = dv_now(1);
    month = dv_now(2);
    day = dv_now(3)-1;
end

for i=day
   try,
      startDate   = datenum(year,month,i, 0.5, 0,0);
      endDate     = datenum(year,month,i,24.0 , 0,0);
      
      stats = fr_calc_rmy(SiteId,startDate,endDate);
      c = stats.Configuration(1);
      eval(['RMY_' c.ext(2:end) ' = stats;']);
      clear stats
      eval(['stats.RMY_' c.ext(2:end) ' = RMY_' c.ext(2:end) ';']);

      FileName_p     = FR_DateToFileName(startDate);
      FileName       = [c.hhour_path FileName_p(1:6) c.hhour_ext];    % File name for the full set of stats
      FileName_short = [c.hhour_path FileName_p(1:6) 's' c.hhour_ext];% File name for the short set of stats
      
      % save the new files
      save(FileName,'stats');
      
      % save the short version of the 'stats'. 
      eval(['stats.RMY_' c.ext(2:end) '.Configuration = [];']);
      eval(['stats.RMY_' c.ext(2:end) '.BeforeRot.Cov = [];']);
      eval(['stats.RMY_' c.ext(2:end) '.AfterRot = [];']);
      eval(['stats.RMY_' c.ext(2:end) '.Fluxes.LinDtr = [];']);
      
      % remove some chamber stuff
      save(FileName_short,'stats');
   end
end	
