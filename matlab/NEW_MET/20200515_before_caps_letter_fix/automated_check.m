function automated_check

addpath D:\Users\kai\autoclean;
addpath D:\Users\kai\autofill;

for i = 1:4
	% Sites = {'BS' 'JP' 'PA' 'CR' 'YF' 'OY'};
	Sites = {'BS' 'CR' 'JP' 'PA'};
	yy = datevec(now);

   SiteId = char(Sites(i));
   
   %------------------------------------------------------------------
   % Get ini file names
   %------------------------------------------------------------------
   pth_proc = biomet_path('Calculation_Procedures\TraceAnalysis_ini',SiteId);
   
   ini_file_first  = fullfile(pth_proc,[SiteId '_FirstStage.ini']);
   ini_file_second = fullfile(pth_proc,[SiteId '_SecondStage.ini']);
   ini_file_third  = fullfile(pth_proc,[SiteId '_Automated.ini']);
   
   %------------------------------------------------------------------
   % Read first stage data
   %------------------------------------------------------------------
   disp([SiteId ' - First stage cleaning']);
   data_raw    = read_data(yy(1),SiteId,ini_file_first);

   %------------------------------------------------------------------
   % Do graphs etc.
   %------------------------------------------------------------------
	autograph_check(data_raw)
   
   clear all
   
end

exit 

return
