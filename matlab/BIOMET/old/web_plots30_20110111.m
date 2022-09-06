%  web_plots30.m
%
%   This function plots selected data from the corrected UBC climate station data
%
%   This is a cannibalized version of Zoran's plot programs
%
% (c)                       File created:       Oct 6, 1998
%                           Last modification:  Jan 29, 2002
%

% Revisions:
% Feb 6, 2008: new year
% Jan 16, 2007: new year
% Jul 4, 2006 modified to make figs in landscape mode %praveena
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

set(0,'DefaultLineLinewidth',2);
set(0,'DefaultAxesLinewidth',2);

 orient portrait;
colordef none
corrected = 0; % default to uncorrected data
year = 2010;
GMTshift = 8/24;                                    % ubc data is in GMT


%in_pth = '\\ANNEX001\DATABASE\2008\UBC_Climate_Stations\Totem';
in_pth = '\\ANNEX001\DATABASE\2010\UBC_Totem\Climate\Totem1';
out_pth = '\\paoa001\web_page_wea\';

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

if 1==1
   
num_days = 16;					% number of days to be plotted

start_date = datenum(2009,12,31);
ed = fix(now - start_date)+1;
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
orient landscape

for i = 5:29
   col_id = num2str(i);
   c = sprintf('c%s=read_bor(%s%s%s%s%s,[],[],[],indOut);',col_id,39,in_pth,filename,col_id,39);
   eval(c); 
end

for n = 1
   %----------------------------------------------------------
   % create first graph
   % air temp/soil temps
   %----------------------------------------------------------
	air_temp = c5(ind);
   
   figure(1);
	subplot(2,1,1);plot(t,air_temp,'m');
   air_hi = ceil(max(air_temp)/5)*5;
   air_lo = ceil(min(air_temp)/5)*5-5;
   if air_lo < -100
      air_lo = 0;
   end
   if air_hi > 40
      air_hi = 30;
   end
	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed air_lo air_hi]);
	title('Air Temperature: 1/2 hourly','color',[1 1 1]);
   ylabel('deg C');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

	soil1 = c8(ind);
	soil2 = c9(ind);
	soil3 = c10(ind);

	subplot(2,1,2);plot(t,soil1,'c',t,soil2,'m',t,soil3,'r');
	soil_hi = ceil(max(soil1)/5)*5;
   soil_lo = ceil(min(soil1)/5)*5-5;
   if soil_lo < -20
      soil_lo = 0;
   end
   if soil_hi > 40
      soil_hi = 30;
   end
	
	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed soil_lo soil_hi]);
	title('Soil Temp: 10 cm-cyan, 20 cm-purple, 40 cm-brown: 1/2 hourly','color',[1 1 1]);
   ylabel('deg C');
   xlabel(sprintf(' (Year = %d)',year));
   datetick('x', 'mm/dd');
   zoom on;
	grid on;
	colordef black
   
    orient portrait
   graph_num = num2str(n);
   d = sprintf('graph_file = %sclim1-%s.jpg%s;',39,graph_num,39);
   eval(d); 

   print( '-djpeg100',[out_pth graph_file])
%	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
%    'color', 'cmyk','height',4,'width',7);

 
   %----------------------------------------------------------
   % create second graph
   % max/min/avg windspeed/ wind direction
   %----------------------------------------------------------
   max_wspd = c24(ind);
   min_wspd= c25(ind);
   wind_speed = c14(ind);

   figure(2);
	subplot(2,1,1);plot(t,wind_speed,t,max_wspd,t,min_wspd);

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
   wind_hi = ceil(max(max_wspd)/5)*5;

   axis([ st ed 0 wind_hi]);
	title('Max / Min / Avg Hourly Windspeed at 10m: 1/2 hourly','color',[1 1 1]);
   ylabel('m/s');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

	wdir = c16(ind);

	subplot(2,1,2);plot(t,wdir,'m');
	set(gca,'XTick',[st:ed],'YTick',[0 90 180 270 360]);
	axis([ st ed 0 400]);
	title('Wind Direction: 1/2 hourly','color',[1 1 1]);
	xlabel(sprintf(' (Year = %d)',year))
   ylabel('deg');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

   colordef black
 orient portrait   
   graph_num = num2str(n);
   d = sprintf('graph_file = %sclim2-%s.jpg%s;',39,graph_num,39);
   eval(d); 

      print( '-djpeg100',[out_pth graph_file])
      
%	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
%    'color', 'cmyk' ,'height',4,'width',7);
 
	%----------------------------------------------------------
   % create third graph
   % rain / RH
   %----------------------------------------------------------
   rain = c26(ind);
   
   figure(3); 
   subplot(2,1,1);plot(t,rain,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 8]);
	title('Rainfall: 1/2 hourly','color',[1 1 1]);
   ylabel('mm');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;
   
   RH = c6(ind);
   
   subplot(2,1,2);plot(t,RH,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 110]);
	title('RH: 1/2 hourly','color',[1 1 1]);
   ylabel('%');
   xlabel(sprintf(' (Year = %d)',year));
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

	colordef black
 orient portrait   
   graph_num = num2str(n);
   d = sprintf('graph_file = %sclim3-%s.jpg%s;',39,graph_num,39);
   eval(d); 

      print( '-djpeg100',[out_pth graph_file])
%	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
%    'color', 'cmyk' ,'height',4,'width',7);
 
	%----------------------------------------------------------
   % create fourth graph
   % Air temp / Solar
   %----------------------------------------------------------
   air_temp = c5(ind);

   figure(4);
	subplot(2,1,1);plot(t,air_temp,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed air_lo air_hi]);
	title('Air Temperature: 1/2 hourly','color',[1 1 1]);
   ylabel('deg C');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

   
   solar = c7(ind);
   
   subplot(2,1,2);plot(t,solar,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 1000]);
	title('Solar Radiation: 1/2 hourly','color',[1 1 1]);
   ylabel('Watts / m^2');
   xlabel(sprintf(' (Year = %d)',year));
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

	colordef black
 orient portrait   
   graph_num = num2str(n);
   d = sprintf('graph_file = %sclim4-%s.jpg%s;',39,graph_num,39);
   eval(d); 

      print( '-djpeg100',[out_pth graph_file])
%	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
%    'color', 'cmyk' ,'height',4,'width',7);
 
	%----------------------------------------------------------
   % create fifth graph
   % Battery:Phone Voltage / FWTC's
   %----------------------------------------------------------
   bat_volt = c12(ind);
	phone_volt = c20(ind);

   figure(5);
	subplot(2,1,1);plot(t,bat_volt,'m',t,phone_volt,'b');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 10 15]);
	title('Voltages: 1/2 hourly','color',[1 1 1]);
   ylabel('volts');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

   
   stevens_fwtc = c22(ind);
   twr2m_fwtc = c23(ind);

   subplot(2,1,2);plot(t,stevens_fwtc,'m',t,twr2m_fwtc,'b');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 15]);
	title('FWTCs: 1/2 hourly','color',[1 1 1]);
   ylabel('deg C');
   xlabel(sprintf(' (Year = %d)',year));
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

	colordef black
 orient portrait   
   graph_num = num2str(n);
   d = sprintf('graph_file = %sclim5-%s.jpg%s;',39,graph_num,39);
   eval(d); 

      print( '-djpeg100',[out_pth graph_file])
%	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
%    'color', 'cmyk' ,'height',4,'width',7);
 
   %----------------------------------------------------------
   % create sixth graph
   % Rain / Cumulative Rain
   %----------------------------------------------------------
   rain = c26(ind);
   

   figure(6);
   subplot(2,1,1);plot(t,rain,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 8]);
	title('Rainfall: 1/2 hourly','color',[1 1 1]);
   ylabel('mm');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

   
   rain = c26(indx);
   cum_rain = (cumsum(rain));
   
   subplot(2,1,2);plot(t,cum_rain(ind) ,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
%  rain_hi = (round(max(cum_rain+10)/100))*100;
   rain_hi = ceil(max(cum_rain)/50)*50;
%   rain_lo = rain_hi - 150.0;
   rain_lo = ceil(min(cum_rain(ind(1)))/50)*50-50;
   axis([ st ed rain_lo rain_hi]);
	title('Cumulative Rain: From Jan 1: 1/2 hourly','color',[1 1 1]);
   ylabel('mm');
   xlabel(sprintf(' (Year = %d)',year));
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

   
   colordef black
 orient portrait   
   graph_num = num2str(n);
   d = sprintf('graph_file = %sclim6-%s.jpg%s;',39,graph_num,39);
   eval(d); 

      print( '-djpeg100',[out_pth graph_file])
%	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
%    'color', 'cmyk' ,'height',7);
 
 %----------------------------------------------------------
 % create seventh graph
 % Air temp / Snow depth
 %----------------------------------------------------------
   air_temp = c5(ind);

   figure(7);
	subplot(2,1,1);plot(t,air_temp,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed air_lo air_hi]);
	title('Air Temperature: 1/2 hourly','color',[1 1 1]);
   ylabel('deg C');
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

   
   snow = c29(ind);
%   rain_hi = ceil(max(cum_rain)/50)*50;
	snow_hi = ceil(max(snow)/0.05)*0.05;
   if snow_hi <= 0
      snow_hi = 0.02;
   end
   subplot(2,1,2);plot(t,snow,'m');

	set(gca,'XTickLabel',[],'XTick',[st:ed]);
	axis([ st ed 0 snow_hi]);
	title('Snow Depth: 1/2 hourly','color',[1 1 1]);
   ylabel('meters');
   xlabel(sprintf(' (Year = %d)',year));
   datetick('x', 'mm/dd');
	zoom on;
	grid on;

	colordef black
 orient portrait   
   graph_num = num2str(n);
   d = sprintf('graph_file = %sclim7-%s.jpg%s;',39,graph_num,39);
   eval(d); 

      print( '-djpeg100',[out_pth graph_file])
%	exportfig(gcf,[out_pth graph_file], 'Format','jpeg', 'fontmode','fixed', 'fontsize',12,...
%    'color', 'cmyk' ,'height',4,'width',7);
 
end % end for n = 1:3
end


