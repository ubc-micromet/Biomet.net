function [Tair_monthly, prec_monthly, station_stats] = ec_climate_normals(SiteId,legacy_flag);
% EC_CLIMATE_NORMALS Environment Canada climate normals for station closest to site
%    [TAIR, PRECIP] = EC_CLIMATE_NORMALS returns the average mean monghtly air 
%    temperature and average total monthly precipitation given by Environment 
%    Canada for the station closest to fr_current_siteid.
%
%    [TAIR, PRECIP] = EC_CLIMATE_NORMALS(SITE) returns the same variables for the 
%    station closest to the site id SITE.
%
%    [TAIR, PRECIP,STATION_STATS] = EC_CLIMATE_NORMALS(SITE) also returns a 
%    structure STATION_STATS that has the following elements:
%    station            - Name of Env. Can. station
%    location           - String containing latitude and longitude of the station
%    elevation          - Elevation of the station
%    T_annual           - Annual average temperature 
%    precip_annual      - Annual total precipitation
%    period             - Period the normals were averaged from (usually 1971 to 2000)
%    
%    The values are climate normals for 1971 to 2000 and were retrieved on 
%    Nov 19, 2002 from the following web site:
%
%    http://www.msc-smc.ec.gc.ca/climate/climate_normals/index_e.cfm
%
%    [TAIR, PRECIP] = EC_CLIMATE_NORMALS('CR',0) returns the normals values 
%    for Campbell River Airport for 1961 to 1990 that were used in the 
%    Biomet Group up to mid-2002 to represent the CR sites.
%
%    EC_CLIMATE_NORMALS(SITE,1) returns climate normals for all sites for 
%    1971 to 2000. 
%    
%    In 2011 we can add the 1981 to 2010 normals and have them returned for 
%    EC_CLIMATE_NORMALS(SITE,2) - of course, by then I'll be 41 and probably
%    right in the middle of my midlife crisis, so I might not be inclined to 
%    do that update.
%

% (c) Kai Morgenstern   File created:       Nov 19, 2002
%                       Last modification:  Nov 25, 2002 

%Revisions:  Nov 25, 2002 E.Humphreys - changed YF entry to correspond to Comox airport
%Revisions:  Apr 14, 2003,N. Kljun - correction in Berms sites precipitation

if ~exist('SiteId') | isempty (SiteId)
   SiteId = fr_current_siteid;
end

if ~exist('legacy_flag') | isempty (legacy_flag)
   legacy_flag = 1;
end

switch upper(SiteId)
case {'CR' 'OY'}
   station_stats.station 			= 'Campbell River Airport';
   station_stats.location			= 'latitude 49deg 57min N, longitude 125deg 16min W';
	station_stats.elevation			= 105.5;  % m
   station_stats.T_annual			= 8.6;    % degC
   station_stats.precip_annual	= 1451.5; % mm
   
   if legacy_flag == 1
	   station_stats.period	= '1971 to 2000';
      % Air temperature (in degrees C)
      Tair_monthly = [1.3  3.0 4.8 7.7 11.2 14.2 16.9 16.9 13.4 8.3 4.2 1.7]';
      % Precipitation (in mm)
      prec_monthly = [198.5 158.7 136.0 84.2 67.1 61.2 40.4 48.6 58.9 152.9 230.7 214.5]';
   elseif legacy_flag == 0
	   station_stats.period	= '1961 to 1990';
      % Air temperature (in degrees C)
		Tair_monthly = [0.9 2.7 4.5 7.2 10.8 14.2 16.7 16.7 13.0 8.1 4.1 1.5]';
		% Precipitation (in mm)
      prec_monthly = [185.7 144.5 136.6 74.5 58.7 49.3 39.5 42.9 61.6 155.4 226.7 233.5]';
   else
      disp(['No values available for ' SiteId]);
      station_stats = [];
      Tair_monthly = []';
	  prec_monthly = []';
   end
   
case {'YF'}
   station_stats.station 			= 'Comox Airport';
   station_stats.location			= 'latitude 49deg 43min N, longitude 124deg 54min W';
	station_stats.elevation			= 25.6;  % m
   station_stats.T_annual			= 9.7;    % degC
   station_stats.precip_annual	= 1179.0; % mm
   
   if legacy_flag == 1
      station_stats.period	= '1971 to 2000';
      % Air temperature (in degrees C)
      Tair_monthly = [  3.0   4.2   5.8   8.6   12.1   15.0   17.6   17.6   14.2   9.3   5.5   3.4 ]';
      % Precipitation (in mm)
      prec_monthly = [168.7   132.3   110.9   61.6   46.6   44.2   29.7   34.8   45.0   120.7   203.4   181.1 ]';
   elseif legacy_flag == 0
      disp(['No old values available for ' SiteId]);
      station_stats.period	= '1971 to 2000 - no data available';
      Tair_monthly = []';
      prec_monthly = []';
   else
      disp(['No values available for ' SiteId]);
      station_stats = [];
      Tair_monthly = []';
      prec_monthly = []';
   end
      
case {'BS' 'JP' 'PA'}
   station_stats.station 			= 'Waskesiu Lake';
   station_stats.location			= 'latitude 53deg 55min N, longitude 106deg 05min W';
	station_stats.elevation			= 532.2;  % m
   station_stats.T_annual			= 0.4;    % degC
   station_stats.precip_annual	= 467.2; % mm
   
   if legacy_flag == 1
	  station_stats.period	= '1971 to 2000';
      % Air temperature (in degrees C)
      Tair_monthly = [-17.9 -14.3 -7.3 2.0 9.3 13.8 16.2 14.7 8.9 2.8 -7.4 -16.4]';
      % Precipitation (in mm)
      prec_monthly = [21.1 13.8 20.8 27.5 47.0 75.2 80.6 59.7 49.9 24.4 23.1 24.2]';
   elseif legacy_flag == 0
      disp(['No old values available for ' SiteId]);
	   station_stats.period	= '1971 to 2000 - no data available';
      Tair_monthly = []';
	  prec_monthly = []';
   else
      disp(['No values available for ' SiteId]);
      station_stats = [];
      Tair_monthly = []';
	  prec_monthly = []';
   end
   
end

   
