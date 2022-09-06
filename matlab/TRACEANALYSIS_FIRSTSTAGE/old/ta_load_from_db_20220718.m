function trace_out = ta_load_from_db(trace_in) 
%This function reads from the database using the information present in the 'ini'
%structure located as a field in the input 'trace_in'.
%This 'ini' structure should contain an 'inputFileName' as a field.
%The 'inputFileName' gives the name of the raw, uncleaned binary data file located
%in the database, associated with 'trace_in'.
%Also, the inputFileName should include the partial path to the file, since
%the biomet_path function used here only return the path to databas

%The result is the same as 'trace_in' except with three new fields: data,data_old,DOY
%which are raw data, and the decimal day of year with time shift.

%Revisions: Elyn 07.11.01 - allow for different inputFileNames associated with different times
%                   for eg. when a sensor is changed from one logger to another

Year = trace_in.Year;
SiteID = trace_in.SiteID;
time_shift = trace_in.Diff_GMT_to_local_time;

pth = biomet_path(Year,SiteID, trace_in.ini.measurementType);		%find path in database

if isfield(trace_in.ini,'inputFileName_dates')
    pick_year = datevec(trace_in.ini.inputFileName_dates(:,1)); %check 1st column
    ind_year  = find(pick_year(:,1) <= Year);
    if ~isempty(ind_year); %allow tv to be loaded and empty trace created even if data not available
        ind_year  = floor(ind_year(end));
        tmp_inputFileName = char(trace_in.ini.inputFileName(ind_year));
    else
        for i = 1:size(pick_year,1);
            tmp_FileName = char(trace_in.ini.inputFileName(i));
            ind = find( tmp_FileName == '\' | tmp_FileName == '.' );
            tmp_FileName = tmp_FileName(1:ind-1);
            if exist([pth tmp_FileName],'dir') == 7;
                tmp_inputFileName = char(trace_in.ini.inputFileName(i));
                break
            end
        end    
    end
else
    tmp_inputFileName = char(trace_in.ini.inputFileName);
end

% switch trace_in.ini.measurementType
% case {'BERMS'}
%    fn      = tmp_inputFileName;		
%    chgfile = find(fn=='\');   %All BERMS climate data is in subdirectories that are used here!
%    fn      = [fn(1:chgfile(end)) 'clean_tv'];	
% case {'cl','fl','ch','pr'}  
%    %find time vector file by changing extension: assume has extension '_tv'
%    fn      = tmp_inputFileName;		%get file name from ini_file
%    chgfile = find(fn=='.');
%    fn      = [fn(1:chgfile(end)-1) '_tv'];	
% otherwise
%    %on the off-chance that there isn't a database tv for that particular trace type
%    tmp_inputFileName = 'avgar.1';
%    pth = biomet_path(Year,SiteID, 'fl');		%find path in database
% end
% 
% %load time vector and day of year for each trace_str
% if exist(fullfile(pth,'TimeVector'))
%     timeVector = (fullfile(pth,'TimeVector'),8);
% else
%     timeVector = read_bor([pth fn],8);
% end

if isfield(trace_in.ini,'inputFileName_dates')
    for i = 1:size(char(trace_in.ini.inputFileName),1)
        [temp_data_cur,timeVector] = read_db(Year,SiteID,...
            trace_in.ini.measurementType,char(char(trace_in.ini.inputFileName(i))));
        ind = find(timeVector >= trace_in.ini.inputFileName_dates(i,1) & ...
            timeVector < trace_in.ini.inputFileName_dates(i,2));
        if i == 1
            temp_data = NaN.*ones(length(timeVector),1);
        end
        if length(temp_data_cur) ~= 1
            temp_data(ind) = temp_data_cur(ind);
        end
        
%        if ~isempty(ind);
%             try,
%                 temp_data(ind) = read_bor([pth char(trace_in.ini.inputFileName(i))],[],[],[],ind);			%read from database
%             end
%        end
    end
else
    [temp_data,timeVector] = read_db(Year,SiteID,...
        trace_in.ini.measurementType,char(tmp_inputFileName));
    %temp_data = read_bor([pth char(tmp_inputFileName)]);
end

% kai* May 25, 2001
% Before, time vector was not rounded
% To avoid errors due to rounding, round timevector to seconds
% timeVector = round(timeVector.*86400)./86400;

%*Elyn Oct 24, 2001
% Changed end time to <= from < so as not to lose last half hour
% indOut = find(timeVector >= datenum(trace_in.Year,1,1) & ...
%           timeVector <= datenum(trace_in.Year+1,1,1));

trace_in.data       = temp_data;
trace_in.DOY        = timeVector - datenum(Year,1,0);
trace_in.DOY        = trace_in.DOY - time_shift/24;
trace_in.timeVector = timeVector;
trace_in.data_old   = trace_in.data;
trace_out           = trace_in;


