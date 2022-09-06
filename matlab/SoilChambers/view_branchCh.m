function x = view_branchCh(DOYs,year,siteID,select)
%view_branchCh(154:158,2007,'BS')
%
%This function plots selected data from the chamber files (branch chamber). It reads from
%the long form hhour files.
%
%(c) David Gaumont-Guay           
%
% File created:       June 7, 2007
close all;
colordef none
pos = get(0,'screensize');
set(0,'defaultfigureposition',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);      % universal

if ~exist('siteID') | isempty(siteID)
    siteID = 'BS';
end

siteID = upper(siteID);

if nargin < 4 
    select = 0;
end
if nargin < 2 | isempty(year)
    year = datevec(now);                    % if parameter "year" not given
    year = year(1);                         % assume current year
end
if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 6/24;

if year >= 1998
   switch upper(siteID)
      case 'BS',pth = '\\paoa001\Sites\PAOB\hhour\';fileExt = '.hb_ch.mat';
      otherwise
           pth = ['\\paoa001\Sites\' siteID '\hhour\'];fileExt = ['s.h' siteID '.mat'];
   end
else
    error 'Data for the requested year is not available!'
end

st = min(DOYs);                              % first day of measurements
ed = max(DOYs);                              % last day of measurements (approx.)

yearOffset = datenum(year,1,1,0,0,0)-1;
dateNow = st+yearOffset;

fig = 0;

%high frequency co2 (slopes) stats
try
   fileName = FR_DateToFileName((ed+yearOffset)+1/48);
   fileName = fileName(1:6);
   x = [pth fileName fileExt];
   eval(['load ' x]);
       if exist('Stats') == 1
                stats.Chambers = Stats.Chambers;
                stats.DecDOY = Stats.Chambers.Time_vector_HH-datenum(2006,1,0);
                clear Stats;
            else
                stats.Chambers = Stats;
                stats.DecDOY = Stats.Time_vector_HH-datenum(2006,1,0);
                clear Stats; 
       end

   t1     = stats.Chambers.Time_vector_HF_short;
   t1_ind = stats.Chambers.Time_ind;
   t_co2  = interp1(t1_ind,t1,t1_ind(1):t1_ind(end));    
   co2    = stats.Chambers.CO2_HF_short; 

   fig = fig+1;figure(fig);clf
   plot(t_co2,co2);
   axis([t_co2(1) t_co2(end) -20 600]);
   datetick('x',15);
   grid on;zoom on;
   xlabel('DOY')
   title('High-freq. CO2 measurements (last day of requested period)');
   ylabel('ppm');
catch
   warndlg('High frequency data for the last day of requested period is not available')
end

%Bole + branch chmaber for SOBS
try
   fileName = FR_DateToFileName((ed+yearOffset)+1/48);
   fileName = fileName(1:6);
   x = [pth fileName fileExt];
   eval(['load ' x]);
       if exist('Stats') == 1
                stats.Chambers = Stats.Chambers;
                stats.DecDOY = Stats.Chambers.Time_vector_HH-datenum(2006,1,0);
                clear Stats;
            else
                stats.Chambers = Stats;
                stats.DecDOY = Stats.Time_vector_HH-datenum(2006,1,0);
                clear Stats; 
       end

   t1     = stats.Chambers.Time_vector_HF_short;
   t1_ind = stats.Chambers.Time_ind;
   t_temp  = interp1(t1_ind,t1,t1_ind(1):t1_ind(end));    
   temp   = stats.Chambers.BranchCh_Stats.Temp_HF; 
   climCtrl   = stats.Chambers.BranchCh_Stats.ClimControl_HF; 

   fig = fig+1;figure(fig);clf
   plot(t_temp,temp(:,1),'y');
   hold on;
   plot(t_temp,temp(:,2),'g');
   plot(t_temp,temp(:,3),'g');
   plot(t_temp,temp(:,4),'g');
   plot(t_temp,temp(:,5),'b');
   plot(t_temp,temp(:,6),'r');
   plot(t_temp,temp(:,7),'c');
   plot(t_temp,temp(:,8),'m');
   hold off;
   axis([t_temp(1) t_temp(end) -5 35]);
   datetick('x',15);
   legend('Outside air','Inside air 1','Inside air 2','Inside air 3','PC inside','PC outside','Wall 1','Wall 2');
   legend boxoff;
   grid on;zoom on;
   xlabel('DOY')
   title('High-freq. branch chamber temperature measurements (last day of requested period)');
   ylabel('^oC');

   fig = fig+1;figure(fig);clf
   plot(t_temp,temp(:,1),'y');
   hold on;
   plot(t_temp,climCtrl(:,4),'g');
   plot(t_temp,temp(:,5),'b');
   plot(t_temp,temp(:,6),'r');
   plot(t_temp,climCtrl(:,5),'c');
   hold off;
   axis([t_temp(1) t_temp(end) -5 35]);
   datetick('x',15);
   legend('Outside air','Inside air Avg','PC inside','PC outside','Wall Avg');
   legend boxoff;
   grid on;zoom on;
   xlabel('DOY')
   title('High-freq. branch chamber temperature measurements (last day of requested period)');
   ylabel('^oC');

   fig = fig+1;figure(fig);clf
   subplot(2,1,1);
   plot(t_temp,climCtrl(:,1),'b');
   axis([t_temp(1) t_temp(end) 0 100]);
   datetick('x',15);
   legend('RH inside branch chamber');
   legend boxoff;
   grid on;zoom on;
   xlabel('DOY')
   title('High-freq. RH measurements for branch chamber (last day of requested period)');
   ylabel('%');

   subplot(2,1,2);
   plot(t_temp,climCtrl(:,2),'b');
   axis([t_temp(1) t_temp(end) -10 2000]);
   datetick('x',15);
   legend('PAR inside branch chamber');
   legend boxoff;
   grid on;zoom on;
   xlabel('DOY')
   title('High-freq. PAR measurements inside branch chamber (last day of requested period)');
   ylabel('%');

   zoom_together(figure(fig),'x','on');
   
   fig = fig+1;figure(fig);clf
   plot(t_temp,climCtrl(:,3),'b');
   hold on;
   plot(t_temp,climCtrl(:,4),'r');
   plot(t_temp,climCtrl(:,5),'g');
   plot(t_temp,climCtrl(:,6),'c');
   plot(t_temp,climCtrl(:,8),'m');
   plot(t_temp,climCtrl(:,9),'y');   
   hold off;
   axis([t_temp(1) t_temp(end) -10 35]);
   datetick('x',15);
   legend('T Dew','Inside air Avg','Wall Avg','Outside air RunAvg','Delta T Allowed','Delta T Measured');
   legend boxoff;
   grid on;zoom on;
   xlabel('DOY')
   title('High-freq. climate control measurements for branch chamber (last day of requested period)');
   ylabel('%');

catch
   warndlg('High frequency data for the last day of requested period is not available')
end

childn = get(0,'children');
childn = sort(childn);
N = length(childn);
for i=childn(:)';
    if i < 200 
        figure(i);
%        if i ~= childn(N-1)
            pause;
%        end
    end
end

close all;