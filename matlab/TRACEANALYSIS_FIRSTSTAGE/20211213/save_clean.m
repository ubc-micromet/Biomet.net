function err = save_clean(trace_in)
%this function is used to export traces to the low level cleaned
%directories in the database.
%INPUT:	-trace_in, a structure contain the following necessary fields
%				trace_in.Year 			= 2000
%						  .SiteID 		= 'pa'
%						  .ini.measurementType = 'fl'
%						  .data = [ a column of the cleaned trace data];
%
%OUTPUT:		trace_in with the new data fields
err=1;
try
   Year = trace_in.Year;
   SiteID = trace_in.SiteID;
   dbpth = biomet_path(Year,SiteID,trace_in.ini.measurementType);   
   
   if strcmp(upper(type_of_measurements),'HIGH_LEVEL') == 0
      dbpth_fn  = [dbpth 'Clean' filesep trace_in.variableName];
	   dbpth_doy = [dbpth 'Clean' filesep 'clean_tv'];
   else
      dbpth_fn  = [dbpth trace_in.variableName];
	   dbpth_doy = [dbpth 'clean_tv'];
	end
   
   data = trace_in.data;
   tv   = trace_in.timeVector;
catch
   err=0;
   return
end
try
   save_bor(dbpth_fn,1,data);
   save_bor(dbpth_doy,8,tv);
catch
   err = 0;
end



