function err = save_lowLevel_clean(trace_in)
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
   dbpth = biomet_path_new(Year,SiteID,trace_in.ini.measurementType);   
   
   dbpth_fn = [dbpth 'Clean' filesep trace_in.variableName]
   % kai* 10.09.2000
   % This before read
   % dbpth_doy = [dbpth 'Clean' filesep 'DOY']
   % DOY  = trace_in.DOY;
   % But the time vector should be the same as in the uncleaned data.
   dbpth_doy = [dbpth 'Clean' filesep 'clean_tv']
   data = trace_in.data;
   tv   = trace_in.timeVector;
   % end kai*
catch
   err=0;
   return
end
try
   save_bor(dbpth_fn,1,data);
   % kai* 10.09.2000
   % This before read
   % save_bor(dbpth_doy,1,DOY);
   % But the time vector should be the same as in the uncleaned data.
   save_bor(dbpth_doy,8,tv);
   % end kai*
catch
   err = 0;
end



