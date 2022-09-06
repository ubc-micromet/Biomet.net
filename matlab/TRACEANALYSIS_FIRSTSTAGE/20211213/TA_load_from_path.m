function trace_out = ta_load_from_path(trace_in,path) 
%This function reads from the database using the information present in the 'ini'
%structure located as a field in the input 'trace_in'.
%This 'ini' structure should contain an 'inputFileName' as a field.
%The 'inputFileName' gives the name of the raw, uncleaned binary data file located
%in the database, associated with 'trace_in'.
%Also, the inputFileName should include the partial path to the file, since
%the biomet_path function used here only return the path to databas


%The result is the same as 'trace_in' except with three new fields: data,data_old,DOY
%which are raw data, and the decimal day of year with time shift.
Year = trace_in.Year;
SiteID = trace_in.SiteID;
time_shift = trace_in.Diff_GMT_to_local_time;

temp_data = read_bor([path trace_in.ini.inputFileName]);			%read from database

%read the time vector which by convention is named 'tv'

%load time vector and day of year for each trace_str
timeVector = read_bor([path 'tv'],8);

%if always working on a single year only use:
trace_in.data = temp_data;
trace_in.DOY = timeVector - datenum(Year,1,0);
trace_in.DOY = trace_in.DOY - time_shift/24;
trace_in.timeVector = timeVector;
trace_in.data_old = trace_in.data;
trace_out = trace_in;


