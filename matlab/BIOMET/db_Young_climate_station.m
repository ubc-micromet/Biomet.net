function db_Young_climate_station(fileName)
% db_Young_climate_station(stationName,fileName)
%
% fileName = 'C:\Users\zoran\Downloads\Newdale-Hamiota-Oakburn-Data.xls';
%
% Zoran Nesic               File created:       Sep  7, 2022
%                           Last modification:  Sep  7, 2022

%
% Revisions
%


stationName = 'Newdale';
fileName = 'C:\Users\zoran\Downloads\Newdale-Hamiota-Oakburn-Data.xls';
origData = readtable(fileName);

dbPath = fullfile(biomet_database_default,['yyyy\Young\Met\' stationName]);


 
siteData = origData(strcmp(origData.StationName,stationName),:);
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
    if strcmpi(oneField,'TMSTAMP')
        % This is the TimeVector. Rename the field
        for cntRows = 1:length(Stats)
            Stats(cntRows).TimeVector = datenum(Stats(cntRows).(oneField));
        end
        datetimeTV = siteData.TMSTAMP;
        Stats = rmfield(Stats,oneField);
    elseif ~strcmp(foo.class,'double')
        % remove all fields that are not class 'double'
        Stats = rmfield(Stats,oneField);
    end
end

% This particular xls files has some data in it that's not on hourly marks
% See:     '07-Nov-2021 02:00:00'
%          '07-Nov-2021 02:01:00'
% The point repetition (two points for the same hourly period creates 
% trouble in db_save_structure.
% Fix it by keeping only the point that are exactly on the hourly mark
% Create a datetime vector that contains only true hourly values
startDatetime = datenum(datetimeTV(1));
endDatetime   = datenum(datetimeTV(end));
fullHourlyTimeVector = fr_round_time(startDatetime:1/24:endDatetime)';
[~,indGoodHourlyPoints] = intersect(datenum(datetimeTV),fullHourlyTimeVector);
Stats = Stats(indGoodHourlyPoints);

% Table data is now in a proper Stats structure
% save Stats into data base

years = unique(year(datetimeTV));
for currentYear = years(1):years(end)  
    fprintf('Processing: Station = %s for year = %d  ',stationName,currentYear);
    fprintf('   ');
    fprintf('Saving 60-min data to %s folder.\n',dbPath);
    db_save_struct(Stats,dbPath,[],[],60,NaN);
    % now interpolate data from 60- to 30- min time periods
    % and shift it by 30 min forward.
    % generic TimeVector for GMT time
    TimeVector30min = fr_round_time(datenum(currentYear,1,1,0,30,0):1/48:datenum(currentYear+1,1,1));
    Stats30min = interp_Struct(Stats,TimeVector30min);
    db30minPath = fullfile(dbPath,'30min');

    fprintf('Saving 30-min data to %s folder.\n',db30minPath);
    db_save_struct(Stats30min,db30minPath,[],[],30,NaN);
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
    