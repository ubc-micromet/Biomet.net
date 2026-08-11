function db_AB_climate_station(yearIn)

% Haley Alcock              File created:       30 July 2026
%                           Last modification:  30 July 2026
%
% Modified from Zoran/Rosie's db_MB_climate_station.m/db_NT_climate_station.m  

% Usage: e.g. db_AB_climate_stations(2020:2023)
%  yearIn = vector of years to be loaded in (ie. [2020:2023])
% Function to read in hourly data downloaded from the Government of
% Alberta (ie. ACISHourlyData-20130101-20130630-PID123019640.xlsx), convert to half-houly and load into database
% Data can be donwloaded from: 
% https://acis.alberta.ca/acis/weather-data-viewer.jsp
% Raw downloaded data should be placed into, ...projectFolder\Sites\PROVINCIAL\AB\Met

% Notes: 
%   1. Data downloaded from
%       https://acis.alberta.ca/acis/weather-data-viewer.jsp as CSV files.
%   2. Function will read in inputed years and sort data by year and Station name into
%      the datebase in projectFolder\Database\yyyy\PROVINCIAL\AB\Met\StationName\
%   3. Raw data is downloded with hourly timestamp and will be interpolated to a
%      30min timestep within the function
%   4. Data downloaded from https://acis.alberta.ca/acis/weather-data-viewer.jsp
%      may have a missing datapoint at the spring daylight savings due to a bug in the Government of Alberta server. Data without this gap
%     can be requested as a custom data request here: https://acis.alberta.ca/acis/app/data/request/create
%     The function will check to see if this spring data gap exisits and if it does, these gaps will be identified and filled with NaN values.
%
% Revisions:
%

for currentYear = yearIn
    %load in data to matlab from Sites/SiteID/Met to Matlab
    fileName = sprintf('ACISHourlyData-%d*.csv',currentYear);
    provinceDir = 'PROVINCIAL';
    provinceName = 'AB';
    inputPath = fullfile(biomet_sites_default,provinceDir,provinceName,'Met',fileName);
    
    assign_in = 'caller';
    varName = [];
    dateColumnNum = 2;
    timeInputFormat = [];
    colToKeep = [3 Inf];
    structType = 1;
    inputFileType = [];
    modifyVarNames = 0;
    VariableNamesLine = 1;
    rowsToRead = [];
    isTimeDuration =[];

    wildCardPath = inputPath;
    h = dir(wildCardPath);
    x = strfind(wildCardPath,filesep);
    y = strfind(wildCardPath,'.*');

    pth = wildCardPath(1:x(end));

    for i=1:length(h)

        fileName = fullfile(pth,h(i).name);
        %load in datestamp and data from csv
        [~,~,tv,outStruct] = fr_read_generic_data_file(fileName,assign_in,...
                         varName, dateColumnNum,timeInputFormat ,colToKeep,structType,inputFileType,modifyVarNames,VariableNamesLine,rowsToRead,isTimeDuration);
        [datestr(outStruct.TimeVector(1:5)) ones(5,1)*'   ' datestr(tv(1:5))];
        
        tv_dt = datetime(datevec(tv));
        
        %load in station name
        T = readtable(fileName);
        stationName = string(T.StationName(1));
        stationName = strrep(stationName, ' ', ''); %remove spaces
        clear T %not needed anymore

        % look for spring daylight savings skipping an hour -> if skip
        % exists, fill time gap and input NaN for all traces in that hour

            idx1 = find(diff(tv_dt.Hour) > 1);    % find "missing" spring timestamp when time change occurs
            if ~isempty(idx1)
                newTime = tv_dt(idx1) + hours(1);
                tv_dt = [tv_dt(1:idx1); newTime ; tv_dt(idx1+1:end)]; %replace deleted daylight savings hour 
                
                fn = fieldnames(outStruct); %add NaN values for deleted timelight savings timestamp
                for k = 1:numel(fn)
                    field = outStruct.(fn{k});
                    outStruct.(fn{k}) = [field(1:idx1); NaN; field(idx1+1:end)];
                end
            end

            outStruct.TimeVector = datenum(tv_dt);
        % only keep variables that are needed, in order they are defined below:
        % (1) air temperature (degC)
        % (2) relative humidity (%)
        % (3) wind speed (km/h)
        % (4) wind direction (degrees)
        % (5) hourly precipitation (mm)
        % (6) incoming solar radiation (W/m^2)
        % (7) atmospheric pressure (hPa)
        % (8) time vector (now in local standard time; MST for NWT)

        % don't keep this in because variables names slightly different at
        % each station
        % keepFields = {'AirTemp_Avg___C_','RelativeHumidityAvg____','WindSpeed2MAvg__km_h_','WindDir_2MAvg____','Precip__mm_','IncomingSolarRad__W_m2_','TimeVector'};
        % outStruct = rmfield(outStruct, setdiff(fieldnames(outStruct), keepFields));
            
        %create output path structure to database
        dbPath = fullfile(biomet_database_default,'yyyy',provinceDir,provinceName,'Met',stationName);   
        dbPath = char(dbPath); %double to single quotes needed for db_struct2datebase.m
        %load 60 minute data to datavase
        missingPointValue = NaN; 
        timeUnit= '60MIN'; 
        structType = 1; 
        db_struct2database(outStruct,dbPath,0,[],timeUnit,missingPointValue,structType,1);
        
        %convert to 30 minutes and load to database
        TimeVector30min = fr_round_time(datenum(currentYear,1,1,0,30,0):1/48:datenum(currentYear+1,1,1));
        Stats30min = interp_Struct(Stats,TimeVector30min);
        db30minPath = fullfile(dbPath,'30min');
        db_struct2database(Stats30min,db30minPath,0,[],'30MIN',missingPointValue,0,1);
        %do again in case file spans two years
        yrs = unique(year(tv_dt));
        if length(yrs) >1
            TimeVector30min = fr_round_time(datenum(currentYear+1,1,1,0,30,0):1/48:datenum(currentYear+2,1,1));
            Stats30min = interp_Struct(Stats,TimeVector30min);
            db30minPath = fullfile(dbPath,'30min');
            db_struct2database(Stats30min,db30minPath,0,[],'30MIN',missingPointValue,0,1);
        end

    end
end


function Stats_interp = interp_Struct(Stats,TimeVector30min)
    % time-shifted ECCC time vector
    tv_ECCC60min = get_stats_field(Stats,'TimeVector')+1/48;  % 1/48 is the 30-min forward shift of ECCC data
    % find the time period
    TimeVector30min = TimeVector30min(TimeVector30min >= tv_ECCC60min(1) & TimeVector30min <= tv_ECCC60min(end)); 
    
    N = length(TimeVector30min);
    % interpolate all data traces to go from 60-min to 30-min
    % period    
    fnames= fieldnames(Stats);
    for k = 1:numel(fnames)
        if ~strcmpi(char(fnames{k}),'TimeVector')
            % extract 60-min data
            x60min = get_stats_field(Stats,char(fnames{k}));
            % interpolate it to double the samples (30-min)
            x = interp1(tv_ECCC60min,x60min,TimeVector30min,'linear','extrap');
		    if strcmpi(char(fnames{k}),'Precip')
				x = x/2;
			end
            % create a Stats_interp field
            for cnt=1:N
                Stats_interp(cnt).(char(fnames{k})) = x(cnt); %#ok<*AGROW>
            end
        else
            for cnt=1:N
                Stats_interp(cnt).TimeVector = TimeVector30min(cnt);
            end
        end
    end
       