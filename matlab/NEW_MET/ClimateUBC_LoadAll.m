function climateData = ClimateUBC_LoadAll
%
% Load up all traces for all years up to the present time.
% Get the highest resolution data available
% Calculate means and totals for hourly/daily/monthly/seasonaly/annually
%
% Zoran Nesic               File created:              2010
%                           Last modification: Dec 10, 2020
%
%

% Revisions:
%
% Dec 10, 2020 (Zoran)
%   - modified to run from PAOA001 (Win10, Matlab App Web Server)
%   - pointed path to annex001 (used to point to a copy of the database)
% Sep 22, 2015
%   - Removed all Irradiance==0 and replaced them with NaN's. 
%   - then promptly changed my mind.  See the comments below, search for "Special
%   case" note.
%   


%%
GMT_offset_hours = 8;
GMT_offset = GMT_offset_hours/24;


pathDatabase = '\\annex001\database\yyyy\UBC_Totem\Clean\ThirdStage\';


%% Trace names

%% Load the highest resolution data 
% Load all 30-minute data first
d = datevec(now);
YearsX = 2002:d(1);        
tv_GMT = read_bor(fullfile(pathDatabase,'clean_tv'),8,[],YearsX);

Tair = read_bor(fullfile(pathDatabase,'air_temperature_main'),1,[],YearsX);
Irradiance = read_bor(fullfile(pathDatabase,'global_radiation_main'),1,[],YearsX);
Precipitation = read_bor(fullfile(pathDatabase,'precipitation_main'),1,[],YearsX);
WindSpeed = read_bor(fullfile(pathDatabase,'wind_speed_main'),1,[],YearsX);
WindDirection = read_bor(fullfile(pathDatabase,'wind_direction_main'),1,[],YearsX);
RelativeHumidity = read_bor(fullfile(pathDatabase,'relative_humidity_main'),1,[],YearsX);
SoilTemp10 = read_bor(fullfile(pathDatabase,'soil_temperature_10cm'),1,[],YearsX);
SoilTemp20 = read_bor(fullfile(pathDatabase,'soil_temperature_20cm'),1,[],YearsX);
SoilTemp40 = read_bor(fullfile(pathDatabase,'soil_temperature_40cm'),1,[],YearsX);

%% To make sure that each year has only one kind of HF data the first 8
% hours of GMT data in the year 2002 needs to be converted from half-hourly to
% hourly data.  The next group of statements does that

% first setup the time vector:
tv_GMT = [tv_GMT(2:2:GMT_offset_hours*2); tv_GMT(GMT_offset_hours*2+1:end)];
for i=0:GMT_offset_hours-1
    Tair(i+1) = (Tair(i*2+1)+Tair(i*2+2))/2;
    Irradiance(i+1) = (Irradiance(i*2+1)+Irradiance(i*2+2))/2;
    Precipitation(i+1) = (Precipitation(i*2+1)+Precipitation(i*2+2));  % do not divide precip
    WindSpeed(i+1) = (WindSpeed(i*2+1)+WindSpeed(i*2+2))/2;
    WindDirection(i+1) = (WindDirection(i*2+1)+WindDirection(i*2+2))/2;
    RelativeHumidity(i+1) = (RelativeHumidity(i*2+1)+RelativeHumidity(i*2+2))/2;
    SoilTemp10(i+1) = (SoilTemp10(i*2+1)+SoilTemp10(i*2+2))/2;
    SoilTemp20(i+1) = (SoilTemp20(i*2+1)+SoilTemp20(i*2+2))/2;
    SoilTemp40(i+1) = (SoilTemp40(i*2+1)+SoilTemp40(i*2+2))/2;
end
Tair = [Tair(1:GMT_offset_hours) ; Tair(GMT_offset_hours*2+1:end)];
Irradiance = [Irradiance(1:GMT_offset_hours) ; Irradiance(GMT_offset_hours*2+1:end)];
Precipitation = [Precipitation(1:GMT_offset_hours) ; Precipitation(GMT_offset_hours*2+1:end)];
WindSpeed = [WindSpeed(1:GMT_offset_hours) ; WindSpeed(GMT_offset_hours*2+1:end)];
WindDirection = [WindDirection(1:GMT_offset_hours) ; WindDirection(GMT_offset_hours*2+1:end)];
RelativeHumidity = [RelativeHumidity(1:GMT_offset_hours) ; RelativeHumidity(GMT_offset_hours*2+1:end)];
SoilTemp10 = [SoilTemp10(1:GMT_offset_hours) ; SoilTemp10(GMT_offset_hours*2+1:end)];
SoilTemp20 = [SoilTemp20(1:GMT_offset_hours) ; SoilTemp20(GMT_offset_hours*2+1:end)];
SoilTemp40 = [SoilTemp40(1:GMT_offset_hours) ; SoilTemp40(GMT_offset_hours*2+1:end)];
    
%% Load year 2001 data.  
%  This year is a mixture of 30-minute and 60-minute data.  This program
%  will convert all data to hourly and make the entire year uniformly
%  sampled.
YearsX = 2001;        
tv_tmp_hhour = read_bor(fullfile(pathDatabase,'clean_tv'),8,[],YearsX);
Tair_hhour = read_bor(fullfile(pathDatabase,'air_temperature_main'),1,[],YearsX);
Irradiance_hhour = read_bor(fullfile(pathDatabase,'global_radiation_main'),1,[],YearsX);
Precipitation_hhour = read_bor(fullfile(pathDatabase,'precipitation_main'),1,[],YearsX);
WindSpeed_hhour = read_bor(fullfile(pathDatabase,'wind_speed_main'),1,[],YearsX);
WindDirection_hhour = read_bor(fullfile(pathDatabase,'wind_direction_main'),1,[],YearsX);
RelativeHumidity_hhour = read_bor(fullfile(pathDatabase,'relative_humidity_main'),1,[],YearsX);
SoilTemp10_hhour = read_bor(fullfile(pathDatabase,'soil_temperature_10cm'),1,[],YearsX);
SoilTemp20_hhour = read_bor(fullfile(pathDatabase,'soil_temperature_20cm'),1,[],YearsX);
SoilTemp40_hhour = read_bor(fullfile(pathDatabase,'soil_temperature_40cm'),1,[],YearsX);

tv_tmp_hour = read_bor(fullfile(pathDatabase,'hourly_clean_tv'),8,[],YearsX);
Tair_hour = read_bor(fullfile(pathDatabase,'hourly_air_temperature_main'),1,[],YearsX);
Irradiance_hour = read_bor(fullfile(pathDatabase,'hourly_global_radiation_main'),1,[],YearsX);
Precipitation_hour = read_bor(fullfile(pathDatabase,'hourly_precipitation_main'),1,[],YearsX);
WindSpeed_hour = read_bor(fullfile(pathDatabase,'hourly_wind_speed_main'),1,[],YearsX);
WindDirection_hour = read_bor(fullfile(pathDatabase,'hourly_wind_direction_main'),1,[],YearsX);
RelativeHumidity_hour = read_bor(fullfile(pathDatabase,'hourly_relative_humidity_main'),1,[],YearsX);
SoilTemp10_hour = read_bor(fullfile(pathDatabase,'hourly_soil_temperature_10cm'),1,[],YearsX);
SoilTemp20_hour = read_bor(fullfile(pathDatabase,'hourly_soil_temperature_20cm'),1,[],YearsX);
SoilTemp40_hour = read_bor(fullfile(pathDatabase,'hourly_soil_temperature_40cm'),1,[],YearsX);

ind = find(~isnan(Tair_hhour));
Tair_hour(ind(2:2:end)/2) = (Tair_hhour(ind(1:2:end))+Tair_hhour(ind(2:2:end)))/2;
Irradiance_hour(ind(2:2:end)/2) = (Irradiance_hhour(ind(1:2:end))+Irradiance_hhour(ind(2:2:end)))/2;
Precipitation_hour(ind(2:2:end)/2) = (Precipitation_hhour(ind(1:2:end))+Precipitation_hhour(ind(2:2:end))); % don't divide by 2 (total)
WindSpeed_hour(ind(2:2:end)/2) = (WindSpeed_hhour(ind(1:2:end))+WindSpeed_hhour(ind(2:2:end)))/2;
WindDirection_hour(ind(2:2:end)/2) = (WindDirection_hhour(ind(1:2:end))+WindDirection_hhour(ind(2:2:end)))/2;
RelativeHumidity_hour(ind(2:2:end)/2) = (RelativeHumidity_hhour(ind(1:2:end))+RelativeHumidity_hhour(ind(2:2:end)))/2;
SoilTemp10_hour(ind(2:2:end)/2) = (SoilTemp10_hhour(ind(1:2:end))+SoilTemp10_hhour(ind(2:2:end)))/2;
SoilTemp20_hour(ind(2:2:end)/2) = (SoilTemp20_hhour(ind(1:2:end))+SoilTemp20_hhour(ind(2:2:end)))/2;
SoilTemp40_hour(ind(2:2:end)/2) = (SoilTemp40_hhour(ind(1:2:end))+SoilTemp40_hhour(ind(2:2:end)))/2;

tv_GMT = [tv_tmp_hour; tv_GMT];
Tair =          [Tair_hour; Tair];
Irradiance =    [Irradiance_hour; Irradiance];
Precipitation = [Precipitation_hour; Precipitation];
WindSpeed = [WindSpeed_hour; WindSpeed];
WindDirection = [WindDirection_hour; WindDirection];
RelativeHumidity = [RelativeHumidity_hour; RelativeHumidity];
SoilTemp10 = [SoilTemp10_hour; SoilTemp10];
SoilTemp20 = [SoilTemp20_hour; SoilTemp20];
SoilTemp40 = [SoilTemp40_hour; SoilTemp40];


%%
% Load hourly data
YearsX = 1991:2000;
tv_GMT =        [read_bor(fullfile(pathDatabase,'hourly_clean_tv'),8,[],YearsX,[],1); tv_GMT];
Tair =          [read_bor(fullfile(pathDatabase,'hourly_air_temperature_main'),1,[],YearsX,[],1); Tair];
Irradiance =    [read_bor(fullfile(pathDatabase,'hourly_global_radiation_main'),1,[],YearsX,[],1); Irradiance];
Precipitation = [read_bor(fullfile(pathDatabase,'hourly_precipitation_main'),1,[],YearsX,[],1); Precipitation];
WindSpeed = [read_bor(fullfile(pathDatabase,'hourly_wind_speed_main'),1,[],YearsX,[],1); WindSpeed];
WindDirection = [read_bor(fullfile(pathDatabase,'hourly_wind_direction_main'),1,[],YearsX,[],1); WindDirection];
RelativeHumidity = [read_bor(fullfile(pathDatabase,'hourly_relative_humidity_main'),1,[],YearsX,[],1); RelativeHumidity];
SoilTemp10 = [read_bor(fullfile(pathDatabase,'hourly_soil_temperature_10cm'),1,[],YearsX,[],1); SoilTemp10];
SoilTemp20 = [read_bor(fullfile(pathDatabase,'hourly_soil_temperature_20cm'),1,[],YearsX,[],1); SoilTemp20];
SoilTemp40 = [read_bor(fullfile(pathDatabase,'hourly_soil_temperature_40cm'),1,[],YearsX,[],1); SoilTemp40];


%% Load data before 1990
% Notes:
%   - these data don't have all time points (missing data means missing
%   time stamps too unlike our database) which leads to issues when
%   using fast averaging function assuming that all time points exist
%   - Some traces exist only as daily and some exist as daily and hourly.
%   Extra steps need to be take to make sure the time vectors correspond
tv_old = tv_GMT;
pathDatabase = 'd:\ClimateUBC_database\19xx\UBC_Totem\Clean\ThirdStage\';
% Load up the time vector (non-uniformly spaced)
tv_tmp = fr_round_time(read_bor(fullfile(pathDatabase,'hourly_clean_tv'),8),'hour',1);
% create a time vector that is uniformly spaced, starts where tv_tmp stars
% but ends midnight Dec 31, 1989
tv_new = fr_round_time([tv_tmp(1):1/24:datenum(1991,1,1)]','hour',1);
Ntv = length(tv_new); 
% find where all tv_tmp points fit in tv_new (index IB)
[c,IA,IB] = intersect(tv_new,tv_tmp);
% create temporary storage arrays for all traces
Irradiance_temp = NaN * ones(Ntv,1);
Precipitation_temp = NaN * ones(Ntv,1);
WindSpeed_temp = NaN * ones(Ntv,1);
WindDirection_temp = NaN * ones(Ntv,1);

tv_GMT = [tv_new; tv_GMT];

% Convert time to standard time
tv = tv_GMT - GMT_offset;
%%
% load full trace
tmp = read_bor(fullfile(pathDatabase,'hourly_global_radiation_main'));
% extract the points and put them into an evenly-sampled array
Irradiance_temp(IA) = tmp(IB);
% also convert the units from MJ/m^2 to W/m^2
Irradiance =    [Irradiance_temp * 1000000/3600; Irradiance]; 
% remove all zero Irradiance (assume that Float==0 can happen only
% if the cleaning tool has replace the actual value with a zero
% ind=find(Irradiance==0);Irradiance(ind)=NaN;
% ***NO POINT in doing the above. Special case! 
% - the zeros get returned back during the
% Irradiance avg calculations (see below).  There are many zeros in this
% period because the irradiance was measured only during day time
% (manually) and the night was filled up with zeros.  

%% repeat for other traces
tmp = read_bor(fullfile(pathDatabase,'hourly_precipitation_main'));
Precipitation_temp(IA) = tmp(IB);
Precipitation = [Precipitation_temp; Precipitation];

tmp = read_bor(fullfile(pathDatabase,'hourly_wind_speed_main'));
WindSpeed_temp(IA) = tmp(IB);
WindSpeed = [WindSpeed_temp; WindSpeed];

tmp = read_bor(fullfile(pathDatabase,'hourly_wind_direction_main'));
WindDirection_temp(IA) = tmp(IB);
WindDirection = [WindDirection_temp; WindDirection];

tmp = read_bor(fullfile(pathDatabase,'hourly_wind_direction_main'));
RelativeHumidity_temp = NaN * ones(Ntv,1);
RelativeHumidity = [RelativeHumidity_temp; RelativeHumidity];
%% --------- Daily data only (pre-1990) -------------------------
% Special processing when only daily data is available.
% First create a different tv vector
tv_PST = fr_round_time(read_bor(fullfile(pathDatabase,'daily_clean_tv'),8),'day',1);

% create the new uniformly spaced time vector:
daily_PST = [tv_PST(1):1:datenum(1991,1,1)]';
Ntv = length(daily_PST); 
% find where all tv_PST points fit in daily_PST 
[c,IA,IB] = intersect(daily_PST,tv_PST);

% Join daily_GMT with regular tv_GMT to create a special tv 
% that is used only with this subgroup of traces (daily data only,
% pre-1990). 
tv_Special = [daily_PST ; tv_old(GMT_offset_hours+1:end)-GMT_offset];

% create temporary storage arrays for all traces
Tair_temp       = NaN * ones(Ntv,1);
SoilTemp10_temp = NaN * ones(Ntv,1);
SoilTemp20_temp = NaN * ones(Ntv,1);
SoilTemp40_temp = NaN * ones(Ntv,1);


% Load all the "special" (daily-data-only) traces
tmp = read_bor(fullfile(pathDatabase,'daily_air_temperature_main'));
Tair_temp(IA) = tmp(IB);
Tair = [Tair_temp;Tair(GMT_offset_hours+1:end)];

%% I average PM and AM soil temperatures assuming the names correspond to
%  day-time, night-time average temperature.  This needs to be
%  confirmed!!!!!!!!!
daily_soil_temperature_AM_10cm = read_bor(fullfile(pathDatabase,'daily_soil_temperature_AM_10cm'));
daily_soil_temperature_PM_10cm = read_bor(fullfile(pathDatabase,'daily_soil_temperature_PM_10cm'));
tmp = (daily_soil_temperature_AM_10cm + daily_soil_temperature_PM_10cm)/2 ;
SoilTemp10_temp(IA) = tmp(IB);
SoilTemp10 = [SoilTemp10_temp; SoilTemp10(GMT_offset*24+1:end)];

daily_soil_temperature_AM_20cm = read_bor(fullfile(pathDatabase,'daily_soil_temperature_AM_20cm'));
daily_soil_temperature_PM_20cm = read_bor(fullfile(pathDatabase,'daily_soil_temperature_PM_20cm'));
tmp = (daily_soil_temperature_AM_20cm + daily_soil_temperature_PM_20cm)/2;
SoilTemp20_temp(IA) = tmp(IB);
SoilTemp20 = [ SoilTemp20_temp; SoilTemp20(GMT_offset*24+1:end)];
%%
% 40cm temp has only a few years of AM measurements.  AM and PM are very
% close.  Only 40cm PM values will be used as daily averages.
daily_soil_temperature_AM_40cm = read_bor(fullfile(pathDatabase,'daily_soil_temperature_AM_50cm'));
%daily_soil_temperature_PM_40cm = read_bor(fullfile(pathDatabase,'daily_soil_temperature_PM_50cm'));
%tmp = (daily_soil_temperature_AM_40cm + daily_soil_temperature_PM_40cm)/2;
tmp = daily_soil_temperature_AM_40cm;
SoilTemp40_temp(IA) = tmp(IB);
SoilTemp40 = [ SoilTemp40_temp ; SoilTemp40(GMT_offset*24+1:end)];



%% Calculate means

% Annual means
clear climateData
k = 0;
Years = 1959:d(1);
for currentYear = Years
    k = k+1;
    ind = find(tv > datenum(currentYear,1,1) & ...
               tv <= datenum(currentYear+1,1,1));
    ind_special = find(tv_Special > datenum(currentYear,1,1) & ...
                     tv_Special <= datenum(currentYear+1,1,1));

    climateData(k).Year = currentYear;  %#ok<*SAGROW>
    traceInfo.Year      = currentYear;
    % climateData(k).tv   = tv(ind);
    
    % Tair
    traceInfo.FieldName = 'Tair';  
    traceInfo.Totalize  = 0;
    traceInfo.tv        = tv_Special(ind_special);
    traceInfo.X         = Tair(ind_special);
    traceInfo.Units     = '\circC';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                        climateDataTemp.(traceInfo.FieldName));
    % GDD calculations
    Tair_daily = climateData(k).Tair.Avg.Daily ;
    tv_daily = unique(round(climateData(k).Tair.tv));
    [climateData(k).GDD.Weekly.Data, climateData(k).GDD.Weekly.tv,...
     climateData(k).GDD.GrowingSeason.Data,climateData(k).GDD.GrowingSeason.tv] = ...
                                        TLEF_GDD_calc(Tair_daily,tv_daily,5.5);
    climateData(k).GDD.Total.Annual = sum(climateData(k).GDD.GrowingSeason.Data);
    climateData(k).GDD.Units = '\circC Days';
    climateData(k).GS.Total.Annual = length(climateData(k).GDD.GrowingSeason.Data)*7+7;
    climateData(k).GS.Units = 'Days';

    % SoilTemp10
    traceInfo.FieldName = 'SoilTemp10';  
    traceInfo.Totalize  = 0;
    traceInfo.tv        = tv_Special(ind_special);
    traceInfo.X         = SoilTemp10(ind_special);
    traceInfo.Units     = '\circC';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                    climateDataTemp.(traceInfo.FieldName)); 
     % SoilTemp20
    traceInfo.FieldName = 'SoilTemp20';  
    traceInfo.Totalize  = 0;
    traceInfo.tv        = tv_Special(ind_special);
    traceInfo.X         = SoilTemp20(ind_special);
    traceInfo.Units     = '\circC';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                    climateDataTemp.(traceInfo.FieldName)); 
      % SoilTemp40
    traceInfo.FieldName = 'SoilTemp40';  
    traceInfo.Totalize  = 0;
    traceInfo.tv        = tv_Special(ind_special);
    traceInfo.X         = SoilTemp40(ind_special);
    traceInfo.Units     = '\circC';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                    climateDataTemp.(traceInfo.FieldName)); 
                                
    % Irradiance
    traceInfo.tv        = tv(ind);
    diffX = (diff(traceInfo.tv));
    diffX = [diffX(1); diffX] * 3600 * 24 / 10^6; %Conversion factor to MJ 
    traceInfo.X         = Irradiance(ind).* diffX;
    traceInfo.X(isnan(traceInfo.X(1:end-10)))= 0;   % replace all NaN's with 0s
    traceInfo.FieldName = 'Irradiance';  
    traceInfo.Totalize  = 1;
    
    traceInfo.Units     = 'MJ/m^2'; %'W/m^2'; % 'MJ/m^2'
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                   climateDataTemp.(traceInfo.FieldName));
    % Precipitation
    traceInfo.X         = Precipitation(ind);
    traceInfo.FieldName = 'Precipitation';
    traceInfo.Totalize  = 1;
    traceInfo.tv        = tv(ind);
    traceInfo.Units     = 'mm';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                   climateDataTemp.(traceInfo.FieldName));
    % Wind Speed
    traceInfo.X         = WindSpeed(ind);
    traceInfo.FieldName = 'WindSpeed';
    traceInfo.Totalize  = 0;
    traceInfo.tv        = tv(ind);
    traceInfo.Units     = 'm/s';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                   climateDataTemp.(traceInfo.FieldName));
    % Wind Direction
    traceInfo.X         = WindDirection(ind);
    traceInfo.FieldName = 'WindDirection';
    traceInfo.Totalize  = 0;
    traceInfo.tv        = tv(ind);
    traceInfo.Units     = 'Deg';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                   climateDataTemp.(traceInfo.FieldName));

    % Relative Humidity
    traceInfo.X         = RelativeHumidity(ind);
    traceInfo.FieldName = 'RelativeHumidity';
    traceInfo.Totalize  = 0;
    traceInfo.tv        = tv(ind);
    traceInfo.Units     = '%';
    climateDataTemp     = TLEF_average(traceInfo);
    climateData         = setfield(climateData,{k},traceInfo.FieldName,...
                                   climateDataTemp.(traceInfo.FieldName));
                               
end
