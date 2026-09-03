function db_NWT_climate_stations(stationName,siteID,yearIn)
%function db_NWT_climate_stations(dataFileName,metadataFileName,stationName,siteID) %,site_lat,site_lon)
%
%
% Rosie Howard              File created:       2 April 2025
%                           Last modification:  3 Sept 2026
%
% Modified from Zoran/Rosie's db_Young_climate_station.m  
%
% Usage: e.g. db_NWT_climate_stations('Jean Marie River','SCC',2020)
%       stationName: name of met station used for substitute data. Only one
%       station can be loaded at a time. Function needs to be re-run for
%       each station
%       siteID: site ID for flux site that needs substitute data
%       yearIn: years for which to extract data (ie. 2024:2025)
% Notes: data must be downloaded from https://360.ftsinc.com/420/data-download (Rosie has login/password)
%        and put into projectFolder\Sites\siteID\Met
%
% Revisions:

% 3 September 2026 (Haley)
%     - put looping through years within function
%     - function will now identity all files that begin with the format 
%       fts-data_yyyy...csv. and load in all files where yyyy corresponds with yearIn
%
% 21 August 2025 (Rosie)
%   - Edited output path so data appears directly in Database/yyyy folder,
%     i.e., at same level as 'ECCC' (if it exists), rather than being
%     buried further. This also means plotApp can access these files to
%     easily plot/check extracted data.
%   - Added 'dataYear' input parameter to determine which file to use,
%     instead of having to input the full filename.
%
% 24 April 2025 (Rosie)
%   - Now works for Jean Marie River (closest site to Scotty Creek SCC),
%     for years 2019-2025.
%
% 16 April 2025 (Rosie)
%   - Determined that data files with this name format: "fts-data_2019-01-01T01_00_00.000Z_2020-01-01T00_00_00.000Z.csv"
%     from their FTS system only goes back as far as 13 December 2019.
%
% 9 April 2025 (Rosie)
%   - Started to add functionality to read in lat/lon and find closest
%     station - NOT COMPLETE
%     Metadata is stored in separate file, created by get_NWT_stn_metadata.m.
%
% 3 April 2025 (Rosie)
%   - Downloaded data for NWT contains occasional gaps (completely missing
%     rows/timestamps) so added correction for this using NaN rows with
%     relevant timestamps.

% arguments relating to metadata (not needed if you already know the
% station name) - KEEP for potential future development, selecting station based on
% lat/lon input
%arg_default('metadataFileName','NWT_Station_Metadata.csv');
%arg_default('site_lat',61.3082);    % lat for CA-SCC
%arg_default('site_lon',121.299);    % lon for CA-SCC

% arguments relating to data: yearly files --> downloaded from
% https://360.ftsinc.com/420/data-download (Rosie has login/password)
% Site/system could not handle downloading more than one year at a time
for dataYear = yearIn
    % find correct data file based on year, choose 2019 to 2025 (can only load one year at a time)
    
    dataFileName = sprintf('fts-data_%d*.csv',dataYear);
    
    % KEEP list of all existing data files, station names, and site IDs, used so far, for documentation purposes  (as of 21 August 2025)
    % arg_default('dataFileName','fts-data_2019-01-01T01_00_00.000Z_2020-01-01T00_00_00.000Z.csv');   % 2019 data (starts 13 Dec 2019)
    % arg_default('dataFileName','fts-data_2020-01-01T01_00_00.000Z_2021-01-01T00_00_00.000Z.csv');   % 2020 data
    % arg_default('dataFileName','fts-data_2021-01-01T01_00_00.000Z_2022-01-01T00_00_00.000Z.csv');   % 2021 data
    % arg_default('dataFileName','fts-data_2022-01-01T01_00_00.000Z_2023-01-01T00_00_00.000Z.csv');   % 2022 data
    % arg_default('dataFileName','fts-data_2023-01-01T01_00_00.000Z_2024-01-01T00_00_00.000Z.csv');   % 2023 data
    % arg_default('dataFileName','fts-data_2024-01-01T01_00_00.000Z_2025-01-01T00_00_00.000Z.csv');   % 2024 data
    % arg_default('dataFileName','fts-data_2025-01-01T01_00_00.000Z_2025-04-17T14_00_00.000Z.csv');   % 2025 data
    
    % station names for substitute data: may need more than one as data is patchy
    % arg_default('stationName','Wrigley');   % Wrigley is closest station to SMC site 
    % arg_default('stationName','Jean Marie River');    % closest to SCC site
    
    % other nearby stations
    % arg_default('stationName','Ndulee Crossing');   % Ndulee Crossing is second closest station to SMC site
    % arg_default('stationName','Jean Marie River');    % closest to SCC site
    % arg_default('stationName','Fort Simpson');  
    % arg_default('stationName','H7K202');    % INF Highway 7 km 202
    % arg_default('stationName','Nahanni Butte');  
    % arg_default('siteID','SMC');
    % arg_default('siteID','SCC');
    
    % fullFilePath = ['/Users/rosie/Documents/Micromet/CanPeat/NWT_metData/' fileName];
    fullDataFilePath = fullfile(biomet_sites_default,siteID,'Met',dataFileName);
    %metaDataFilePath = fullfile(biomet_sites_default,siteID,'Met',metadataFileName);   % only needed in this script if code is 
                                                                                        % further developed later to select nearest
                                                                                        % station by lat/lon (see commented out code below,
                                                                                        % does not yet work as of 21 August 2025
    
    % output path
    % first check for spaces in filename (to avoid problems when loading
    dbPath = fullfile(biomet_database_default,'yyyy',stationName); % changed to be in same location as ECCC (directly in Database/yyyy)
    %dbPath = fullfile(biomet_database_default,'yyyy',siteID,'Met',stationName); 
    
    wildCardPath = fullDataFilePath;
    hh = dir(wildCardPath);
    x = strfind(wildCardPath,filesep);
    y = strfind(wildCardPath,'.*');

    pth = wildCardPath(1:x(end));
    
    for i=1:length(hh)
        fileName = fullfile(pth,hh(i).name);

        % Read the full data file
        origData = readtable(fileName);
        % tempData = origData;    %   to preserve origData (don't have to do this)
        siteData = origData(strcmpi(origData.StationName,stationName),:);
        
        %**************** Section to use input lat/lon to find nearest station ****************
        %   Not needed if you know the station you want and is has data for the year you need *
        %**************************************************************************************
        
        % % load in metadata file
        % metaData = readtable(metaDataFilePath);
        % 
        % hourlyData = origData(~(contains(origData.StationName,'ubicom',IgnoreCase=true)),:);    % 'ubicom' is daily data: remove these rows
        % 
        % sitesWithCoords = sort(unique(metaData.name));
        % sitesWithData = sort(unique(hourlyData.StationName));
        % 
        % % make sure longitude is negative
        % if site_lon > 0
        %     site_lon = -site_lon;
        % end
        
        % find nearest station to input lat/lon
        % dist = distance(metaData.Latitude,metaData.Longitude,site_lat,site_lon);
        % ind = find(dist == min(dist));
        % stationName = char(metaData.nameInDataFile(ind));
        % siteData = origData(strcmpi(origData.StationName,stationName),:);
         
        % count = 0;  % set condition to check whether to move on in code, i.e., data exists for the station that is found
        % err_count = 0;
        % while count == err_count
        %     try
        %         % find distances between site location and all stations (uses spherical
        %         % coords)
        %         dist = distance(metaData.Latitude,metaData.Longitude,site_lat,site_lon);
        %         ind = find(dist == min(dist));
        %         stationName = metaData.name(ind);
        % 
        %         % Extract data for stationName
        %         siteData = tempData(strcmpi(origData.StationName,stationName),:);
        % 
        %         if height(siteData) == 0
        %             % remove rows for current station in tempData
        % 
        %         end
        %     catch MyErr
        %         err_count = err_count + 1;
        %     end
        %     count = count + 1;
        % end
        
        % % test plot
        % plot(metaData.Longitude, metaData.Latitude,'x')
        % hold on
        % grid
        % plot(metaData.Longitude(ind), metaData.Latitude(ind),'rx')
        % plot(site_lon,site_lat,'ro')
        
        % look at data, for testing purposes
        % allFields = fieldnames(origData);
        % [~,idx]=sort(lower(allFields));
        % allFields_sorted = allFields(idx);
        % for i = 1:length(allFields_sorted)
        %     var = allFields_sorted{i};
        %     if isnumeric(origData.(var))
        %         plot(origData.(var),'o');
        %         title(var);
        %     else
        %         fprintf([var ' is not numeric\n']);
        %     end
        % 
        % end
        
        %***********************************************************************
        %**** End of section to determine nearest station from input lat/lon ****
        %***********************************************************************
        
        % Format date 
        fmt = "yyyy-MM-dd'T'HH:mm:ss'Z";
        t = datetime(siteData.Date,"InputFormat",fmt); %,"Format","dd-MMM-uuuu HH:mm:ss");
        siteData.Date = t;
        
        % find any duplicates or gaps in datetimeTV (time vector)
        datetimeTV = siteData.Date;
        % startTime = datetimeTV(1);
        % endTime = datetimeTV(end);
        % allRange = startTime:hours(1):endTime;      % could use this instead of adjusting each gap individually...?
        
        % first deal with any duplicates
        dateRangeKnown = datetimeTV; % initialize the datetime objects for which data exists
        gaps = diff(dateRangeKnown);
        ind_zeros = find(gaps == 0);
        if ~isempty(ind_zeros)
            % if there are duplicates, remove them (in the case studied, first
            % occurrence had data, second occurrence appeared to have NaNs, so
            % remove second occurrence)
            datetimeTV(ind_zeros+1) = [];
            siteData(ind_zeros+1,:) = [];
            % recalculate datetimeTV (in case duplicates existed and were removed)
            dateRangeKnown = datetimeTV; % initialize the datetime objects for which data exists
        end
        
        % first find data segments (between any gaps)
        gaps = diff(dateRangeKnown);
        indices = find(gaps > hours(1));  % find gaps larger than one hour 
        
        if ~isempty(indices)
            % first pass: split and store data into sections, store gap sizes
            niterations = length(indices) + 1;  % number of sections of data surrounding gaps, to concatenate
            tempData = cell([niterations 1]);   % initialize cell array to save each section array
            h = NaN(niterations-1,1);             % initialize array to store size of gap (number of data points)
            for gap = 1:length(indices)+1
                if gap == 1     % from start to first gap
                    % first gap
                    tempDataArray = siteData(1:indices(gap),:);
                    h(gap) = hours(gaps(indices(gap)));  % convert gap length to integer (in hours)
                elseif gap > length(indices)   % store last section of data
                    % final gap
                    tempDataArray = siteData(indices(gap-1)+1:end,:);
                else    % remaining in between gaps
                    % in between gaps
                    tempDataArray = siteData(indices(gap-1)+1:indices(gap),:);
                    h(gap) = hours(gaps(indices(gap)));  % convert gap length to integer (in hours)
                end
                tempData{gap,1} = tempDataArray;
                clear tempDataArray
            end
        
            % second pass: stitch data together with NaN rows where gaps are located
            tempDataAll = [];
            for gap = 1:length(indices)+1
                % insert section of data
                tempDataAll = [tempDataAll; tempData{gap}]; %#ok<*AGROW>
                if gap < length(h)+1
                    nanRow = siteData(indices(gap),:);      % get dummy row
                    nanRow = repelem(nanRow,h(gap)-1,1);   % make table correct height for gap (number of hours): if h = 2, only one datapoint is missing
                    % correct the hour for nanRow(s)
                    count = 1;
                    for gap_hour = 1:h(gap)-1
                        nanRow.Date(count) = datetimeTV(indices(gap)) + duration(count,0,0);
                        count = count + 1;
                    end
                    % append nanRow(s)
                    tempDataAll = [tempDataAll; nanRow];
                end
            end
        else
            tempDataAll = siteData;
        end % end if isempty(indices) 
        
        % reassign to siteData now gaps are filled and remove tempData array (to
        % avoid confusion later)
        siteData = tempDataAll;
        clear tempDataAll;
        
        % timezone conversion from UTC (GMT; NWT met data is stored in this timezone), 
        % to local standard time (mountain time for NT sites)
        timezone = "-07:00";
        % timezone = 'America/Inuvik';  % timezone of station location --> NO! This includes daylight savings
        d = datetime(siteData.Date,'TimeZone','UTC');
        d.TimeZone = timezone;
        % apply timezone change everywhere
        siteData.Date = d;
        datetimeTV = d;
        
        % % Unit conversions --> Do this in INI file!
        % siteData.Wspd = siteData.Wspd/3.6;    % convert from km/h to m/s (Ameriflux standard)
        % siteData.Baro = siteData.Baro/10;     % convert from hPa to kPa (Ameriflux standard)
        
        % Convert siteData to Stats structure
        Stats = table2struct(siteData);
        
        % go through all the Stats fields. 
        allFields = fieldnames(Stats);
        % go field by field, convert 'datetime' fields to 'datenum' fields
        % and remove all the other fields that are not 'double'-s
        for cntFields = 1:length(allFields)
            oneField = char(allFields(cntFields));
            foo = Stats(1).(oneField);
            foo = whos('foo');
            if strcmpi(oneField,'Date')
            % if strcmpi(oneField,'TMSTAMP')
                % This is the TimeVector. Rename the field
                for cntRows = 1:length(Stats)
                    Stats(cntRows).TimeVector = datenum(Stats(cntRows).(oneField));
                end
                datetimeTV = siteData.Date;
                % datetimeTV = siteData.TMSTAMP;
                Stats = rmfield(Stats,oneField);
            elseif ~strcmp(foo.class,'double')
                % remove all fields that are not class 'double'
                Stats = rmfield(Stats,oneField);
            end
        end
        
        % only keep variables that are needed, in order they are defined below:
        % (1) air temperature (degC)
        % (2) relative humidity (%)
        % (3) wind speed (km/h)
        % (4) wind direction (degrees)
        % (5) hourly precipitation (mm)
        % (6) incoming solar radiation (W/m^2)
        % (7) atmospheric pressure (hPa)
        % (8) time vector (now in local standard time; MST for NWT)
        keepFields = {'Temp','Rh','Wspd','Dir','Rn_1','PYR','Baro','TimeVector'};
        Stats = rmfield(Stats, setdiff(fieldnames(Stats), keepFields));
        
        % Table data is now in a proper Stats structure
        % save Stats into data base
        years = unique(year(datetimeTV));
        for currentYear = years(1):years(end)  
            fprintf('Processing: Station = %s for year = %d  ',stationName,currentYear);
            fprintf('   ');
            fprintf('Saving 60-min data to %s folder.\n',dbPath);
            db_save_struct(Stats,dbPath,[],[],60,NaN);
            % now interpolate data from 60- to 30- min time periods
            % generic TimeVector for local standard time
            TimeVector30min = fr_round_time(datenum(currentYear,1,1,0,30,0):1/48:datenum(currentYear+1,1,1));
            metData30min = interp_Struct(Stats,TimeVector30min);
            db30minPath = fullfile(dbPath,'30min');
        
            if isempty(metData30min)
                fprintf('')
                fprintf('Check: 30-min data not calculated for %d.\n',currentYear)
                return
            else
                fprintf('Saving 30-min data to %s folder.\n',db30minPath);
                db_save_struct(metData30min,db30minPath,[],[],30,NaN);
            end
        end
    end
end
        
        
        function Stats_interp = interp_Struct(Stats,TimeVector30min)
            % met site time vector
            tv_60min = get_stats_field(Stats,'TimeVector'); 
        
            % find time vector for current year
            t_ST = datetime(TimeVector30min,"ConvertFrom","datenum");   % standard time
            year = unique(t_ST.Year);
            year = year(1); % start of data will have correct year (if defined correctly above)
        
            t_metSite = datetime(tv_60min,"ConvertFrom","datenum");
            ind = find(t_metSite.Year == year);
        
            % shift indices according to timestamp (e.g. first data point in year 2022
            % represents data in year 2021)
            if t_metSite(ind(end)).Month == 12 && t_metSite(ind(end)).Day == 31 && t_metSite(ind(end)).Hour == 23
                ind(end+1) = ind(end)+1;
            else
                ind(1) = [];
            end
            t_metSite = t_metSite(ind(1):ind(end));
            tv_60min = datenum(t_metSite);
            TimeVector30min = TimeVector30min(TimeVector30min >= tv_60min(1)-1/48 & TimeVector30min <= tv_60min(end));
            
        
            % if inFileNum == 1
            %     % shift indices according to timestamp (e.g. first data point in year 2022
            %     % represents data in year 2021)
            %     if t_metSite(ind(end)).Month == 12 && t_metSite(ind(end)).Day == 31 && t_metSite(ind(end)).Hour == 23
            %         ind(end+1) = ind(end)+1;
            %     else
            %         ind(1) = [];
            %     end
            %     t_metSite = t_metSite(ind(1):ind(end));
            %     tv_60min = datenum(t_metSite);
            %     TimeVector30min = TimeVector30min(TimeVector30min >= tv_60min(1)-1/48 & TimeVector30min <= tv_60min(end));
            % elseif inFileNum == 2
            %     TimeVector30min = TimeVector30min(TimeVector30min >= tv_60min(1)-1/48 & TimeVector30min <= tv_60min(end));
            % elseif inFileNum == 3
            %     % shift indices according to timestamp (e.g. first data point in year 2022
            %     % represents data in year 2021)
            %     if t_metSite(ind(end)).Month == 12 && t_metSite(ind(end)).Day == 31 && t_metSite(ind(end)).Hour == 23
            %         ind(end+1) = ind(end)+1;
            %     else
            %         ind(1) = [];
            %     end
            %     t_metSite = t_metSite(ind(1):ind(end));
            %     tv_60min = datenum(t_metSite);
            %     TimeVector30min = TimeVector30min(TimeVector30min >= tv_60min(1)-1/48 & TimeVector30min <= tv_60min(end));
            % else
            %     % shift indices according to timestamp (e.g. first data point in year 2022
            %     % represents data in year 2021)
            %     if t_metSite(ind(end)).Month == 12 && t_metSite(ind(end)).Day == 31 && t_metSite(ind(end)).Hour == 23
            %         ind(end+1) = ind(end)+1;
            %     end
            %     t_metSite = t_metSite(ind(1):ind(end));
            %     tv_60min = datenum(t_metSite);
            %     TimeVector30min = TimeVector30min(TimeVector30min >= tv_60min(1)-1/48 & TimeVector30min <= tv_60min(end));
            % end
        
            if isempty(TimeVector30min)
                Stats_interp = [];
                return
            end
        
            % find the time period - could put this here as applied to all files,
            % but during analysis I found it helpful to see what was being done for
            % each file all at once, above.
            % TimeVector30min = TimeVector30min(TimeVector30min >= tv_60min(1)-1/48 & TimeVector30min <= tv_60min(end));
        
            N = length(TimeVector30min);
            % interpolate all data traces to go from 60-min to 30-min period    
            fnames= fieldnames(Stats);
            for k = 1:numel(fnames)
                if ~strcmpi(char(fnames{k}),'TimeVector')
                    % extract 60-min data
                    % x60min = get_stats_field(Stats,char(fnames{k}));
                    x60min = get_stats_field(Stats(ind),char(fnames{k}));
                    % interpolate it to double the samples (30-min)
                    x = interp1(tv_60min,x60min,TimeVector30min,'linear','extrap');
                        if strcmpi(char(fnames{k}),'Rn_1') % hourly precipitation should be divided by two for half-hour
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
