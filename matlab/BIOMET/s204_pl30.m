%  s204_pl30.m
%
%   This function plots selected data from the corrected UBC climate station data
%
%   This is a cannibalized version of Zoran's plot programs
%
% (c)                       File created:       Oct 6, 1998
%                           Last modification:  Jan 29, 2002
%

% Revisions:
% incorporated into s204 program for 2007
% Jan 8, 2004:  modified to run on PAOA001
% Oct 14, 2003: default to corrected data
% Jan 7, 2003: new year
% Jan 29, 2002: added snow depth plot
% Dec 18, 2001: added feature to auto scale max wind speed and min cum-rain
% Nov 29, 2001: added feature to automatically scale max cum-rain
% June 26, 2001: adjusted some graphs for summer mode
% Mar 8, 2001: corrected t to plot correct year
% Dec 7, 2000: changed computer name from 'dept2' to 'FNH230-02'
% Oct 3, 2000: removed input args

colordef none
corrected = 0; % default to uncorrected data
year = 2014;
GMTshift = 8/24;                                    % ubc data is in local PST


%in_pth = '\\ANNEX001\DATABASE\2009\UBC_Climate_Stations\Climate\Totem';
in_pth = '\\ANNEX001\DATABASE\2014\UBC_Totem\Climate\Totem1';
%out_pth = '\\PAOA001\Sites\web_page_weather\';
out_pth = 'D:\SITES\UBC\';

filename='\ubc.';
indOut    = [];

    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];


t=read_bor([ in_pth '\ubc_dt']);                  % get decimal time from the data base

offset_doy = 0;		% database starts 01-01-2004

t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    

num_days = 10;					% number of days to be plotted

start_date = datenum(2013,12,31);
ed = fix(now - start_date)-6;
st = ed - num_days;
ind = find( t >= st & t <= ed );                    % extract the requested period
indx = find( t >= 0 & t <= ed );
tx = t(indx);
t = t(ind);


t =  t  + start_date;
tx = tx + start_date;
st = st + start_date;
ed = ed + start_date;
%-----------------------------------------------
% Read all data columns

for i = 5:29
   col_id = num2str(i);
   c = sprintf('c%s=read_bor(%s%s%s%s%s,[],[],[],indOut);',col_id,39,in_pth,filename,col_id,39);
   eval(c); 
end

for n = 1

      %----------------------------------------------------------
   % create first graph
   % air temp/soil temp/windspeed/solar
   %----------------------------------------------------------
   figure(1);
	air_temp = c5(ind);
    %air_temp = c23(ind); % use Twr TC to replace bad HMP data from missing Stevenson screen

    colordef black
	subplot(4,1,1);plot(t,air_temp,'r');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 10 25]);
	title('Air Temperature: Height 1.3 m');
	ylabel('deg C');
	zoom on;
	grid on;

	soil_temp10 = c8(ind);
    soil_temp20 = c9(ind);
    soil_temp40 = c10(ind);

	subplot(4,1,2);plot(t,soil_temp10,'c',t,soil_temp20,'b',t,soil_temp40,'g');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 15 25]);
	title('Soil Temperature: Depth 10 cm, 20 cm, 40 cm');
	ylabel('deg C');
	zoom on;
	grid on;

	wind_speed = c14(ind);

	subplot(4,1,3);plot(t,wind_speed,'g');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 10]);
	title('Windspeed: Height 10m');
	ylabel('m/s');
	zoom on;
	grid on;

	solar = 1.3*c7(ind);  % data from uncorrected database: need solar correction
    
	subplot(4,1,4);plot(t,solar,'m');
	set(gca,'XTick',[st:ed],'YTick',[0 500 1000]);
	axis([ st ed 0 1200]);
	title('Solar Radiation');
	xlabel(sprintf('mm/dd (Year = %d)',year))
	ylabel('Watts / m^2');
    datetick('x', 'mm/dd','keepticks');
	zoom on;
	grid on;

	colordef black
   
   graph_num = num2str(n);
   d = sprintf('graph_file = %s204clim1-%s.jpg%s;',39,graph_num,39);
   eval(d); 

	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
       'color', 'cmyk' );
 
   %----------------------------------------------------------
   % create second graph
   % max/min/avg windspeed/ wind direction
   %----------------------------------------------------------
   figure(2);
   max_wspd = c24(ind);
   min_wspd= c25(ind);
   wind_speed = c14(ind);

	subplot(2,1,1);plot(t,wind_speed,'g',t,max_wspd,'r',t,min_wspd,'b');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 20]);
	title('Max / Min / Avg Hourly Windspeed at 10m');
	ylabel('m/s');
	zoom on;
	grid on;

	wdir = c16(ind);

	subplot(2,1,2);plot(t,wdir,'c');
	set(gca,'XTick',[st:ed],'YTick',[0 90 180 270 360]);
	axis([ st ed 0 400]);
	title('Wind Direction');
	xlabel(sprintf('mm/dd (Year = %d)',year))
	ylabel('degrees');
    datetick('x', 'mm/dd','keepticks');
    zoom on;
	grid on;

   colordef black
   
   graph_num = num2str(n);
   d = sprintf('graph_file = %s204clim2-%s.jpg%s;',39,graph_num,39);
   eval(d); 

	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
   'color', 'cmyk' );
 
end


