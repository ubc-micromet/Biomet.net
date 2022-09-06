function trace_out = read_single_trace( trace_in, sourceDB )

if strcmp(trace_in.stage,'first')
   
	if strcmp(sourceDB,'database')
	   try
	      trace_in = load_trace_from_database(trace_in);		%load trace from DB (keeping structure form).
	   catch
   	   trace_in.Error = 1;  %Set the error code to a read error
	   end   
	else   
	   try
	      trace_in = load_trace_from_path(trace_in, sourceDB);		%load trace from inpath(keeping structure form).   catch
	   catch
	      trace_in.Error = 1;  %Set the error code to a read error
	   end   
	   % end kai*
	end
end

if strcmp(trace_in.stage,'second')
   
	if strcmp(sourceDB,'database')
      try
         trace_in = load_trace_from_database_B(trace_in);		%load trace from DB (keeping structure form).
      catch
   	   trace_in.Error = 1;  %Set the error code to a read error
	   end   
	else   
	   try
	      %trace_in = load_trace_from_path(trace_in, sourceDB);		%load trace from inpath(keeping structure form).   catch
	   catch
	      trace_in.Error = 1;  %Set the error code to a read error
	   end   
	   % end kai*
   end
   
end  	
   
trace_out = trace_in;
