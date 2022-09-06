function trace_out = ta_load_traceData(trace_new,file_opts,DOY,interp_flag,clean_flag)
%This function loads the trace data from either the database, or
%at some location specified by the user in the main startup menu.
%-From the Database: the raw data file, with file name listed in the
%							'trace_new.ini.inputFileName' field, is loaded.
%-From Local:  the raw data file with file name 'trace_new.variableName',
%					located in the path 'top.file_opts.in_path', is loaded.
%Either of these input paths should contain uncleaned binary data files.
%The reason is that the ini_file and/or mat_file contains all the necessary
%information to create the cleaned trace.
%After these traces have been loaded this function calls the basic cleaning
%function 'clean_traces'.
%
%	Input:	'trace_new' -The trace structure containing all initializtion information.
%				'file_opts'			-A structure containing the state of the the current trace
%								while using the visual point picking tool(stored in the working
%								axis 'UserData' parameter).
%	Output:	'trace_out'	-The output trace with new fields: data, data_old, DOY.
if ~exist('interp_flag')
   interp_flag = 'yes';
end

% kai* May 25, 2001
% Before, this read
% if ~exist('clean_flag')
% But the exported file clean_flag does exist, so one has to check for the VARIABLE in the 
% current work space
if exist('clean_flag') ~= 1
   clean_flag = 'yes';
end


trace_out = []; %default outputs

%First load the necessary raw data (original uncleaned trace):
try
   if strcmp(file_opts.in_path,'database')               
      %from the database:
      trace_new = ta_load_from_db(trace_new);
   else                
      %from a local input path containing binary files with names given by 
      %the traces 'variableName' field:
      trace_new.data_old = read_bor([file_opts.in_path trace_new.variableName]);
      trace_new.data = trace_new.data_old;
      
      %Uses the same DOY as the current working trace:
      trace_new.DOY = DOY;		
   end          
catch   
   warn_message(['Warning: could not load ' trace_new.variableName '!']);
   return
end   

%do the basic cleaning for the input trace:
if ~strcmp(clean_flag,'no_clean')
   trace_new = clean_traces(trace_new);     
else
   trace_new = clean_traces(trace_new,'no_interp');
end

if isfield(trace_new,'pts_restored') & ~isempty(trace_new.pts_restored)
   trace_new.data(trace_new.pts_restored) = trace_new.data_old(trace_new.pts_restored);
end

if isfield(trace_new,'pts_removed') & ~isempty(trace_new.pts_removed)
   trace_new.data(trace_new.pts_removed) = NaN;
   %Update all points that are currently interpolated:
   if isfield(trace_new,'interpolated') & ~isempty(trace_new.interpolated) ...
         & ~strcmp(interp_flag,'no_interp')
      trace_new.data(trace_new.pts_removed) = ...
         trace_new.interpolated(trace_new.pts_removed); 
   end 
end
trace_out = trace_new;
