function db_ECCC_climate_station(yearRange,monthRange,stationID,dbPath,timeperiod) 
% db_ECCC_climate_station(yearRange,monthRange,stationID,dbPath,timeperiod) 
%
% Inputs:
%   yearRange       - years to process (2020:2022)
%   monthRange      - months to process (1:12)
%   stationID       - station ID
%   dbPath          - path where data goes. It has to contain "yyyy"
%                     (p:\database\yyyy\BB1\MET\ECCC)
%   timePeriod      - data sample rate in minutes (default for ECCC is 60)
%
%
% Zoran Nesic               File created:       Apr  3, 2022
%                           Last modification:  Apr  3, 2022
%

% Revisions:
%

[yearNow,monthNow,~]= datevec(now);
arg_default('yearRange',yearNow);               % degault year is now
arg_default('monthRange',monthNow-1:monthNow)   % default month is previous:current
arg_default('stationID',49088);                 % default station is Burns Bog
arg_default('timeperiod',60);                   % data is hourly (60 minutes)
tempFileName = 'junk9999.csv';  % temp file name

for yearNow = yearRange
    for currentMonth = monthRange
        % load current month (month can be zero or negative if we are processing currentMonth-1:currentMonth)
        if currentMonth <1 
            yearIn = yearNow-1;
            monthIn = currentMonth+12;
        else
            yearIn = yearNow;
            monthIn = currentMonth;
        end
        %fprintf('Processing: StationID = %d, Year = %d, Month = %d\n',stationID,yearIn,monthIn);
        urlDataSource = sprintf('https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=%d&Year=%d&Month=%d&Day=14&timeframe=1&submit=%20Download+Data',...
                                stationID,yearIn,monthIn);
        websave(tempFileName,urlDataSource);
        [Stats,~,~] = fr_read_EnvCanada_file(tempFileName);
        delete(tempFileName);
        % extract time 
        % Note: the time stamp in the ECCC files is set to the middle of the period
        %       10:00am is data avarage for the period of 9:30 to 10:30
        %       This issue will be dealt with in the post processing
        TimeVector = get_stats_field(Stats,'TimeVector');
        for cnt = 1:length(TimeVector)
            Stats(cnt).TimeVector = fr_round_time(TimeVector(cnt));
        end

        datetimeTV = datetime(TimeVector,'convertfrom','datenum');
        years = unique(year(datetimeTV));
        for currentYear = years(1):years(end)
            fprintf('Processing: StationID = %d, Year = %d, Month = %d   ',stationID,currentYear,monthIn);
            fprintf('   ');
            db_save_struct(Stats,dbPath,[],[],timeperiod,NaN);
        end
    end
end