function x = chamber_pl(DOYs,year,siteID,select)
%x = chamber_pl(DOYs,year,siteID,select)
%
%This function plots selected data from the chamber files. It reads from
%the short form hhour files.
%
%(c) David Gaumont-Guay           
%
% File created:       Sep 9, 2002
%
% Last modification:
% - May 28, 2009
%       -set plots of OBS chambers to summer mode (winter_mode = 0) (Nick)
% - May 15, 2008 
%       -added flags describing current chamber config at SOBS (Nick)  
% - Nov 13, 2007
%       - Nick modified OBS for winter_mode display of chamber data (six
%       chambers instead of 12, no root exclusion or VWC plots)      
% - June 7, 2007
%       - added branch chamber data for SOBS (david)
% - Jan 23, 2006
%       - changed file extension for SOA (new chamber calcs) (dgg)
% - June 30, 2005
%       removed conditional plotting of air and soil temperatures (site
%       dependant).  Now one line fits all (trace_path). (Z)
% - Apr 6, 2005
%       plotting for YF will now skip every other half hour. (Z)
% - Nov 4, 2002 - added a winter mode plotting option for effective volumes and fluxes when specific
%                 chambers are in operation at the sites (see line 163).
 

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
      case 'CR',pth = '\\paoa001\Sites\cr\hhour\';fileExt = 's.hc.mat';
      case 'PA',pth = '\\paoa001\Sites\paoa\hhour\';fileExt = 's.hp_ch.mat';
      case 'BS',pth = '\\paoa001\Sites\PAOB\hhour\';fileExt = 's.hb_ch.mat';
      case 'JP',pth = '\\paoa001\Sites\PAOJ\hhour\';fileExt = 's.hj.mat';
      case 'YF',pth = '\\paoa001\Sites\YF\hhour\';fileExt = 's.hy_ch.mat';
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

%load time vector
[DecDOY,TimeVector] = ach_join_trace('stats.Chambers.Time_vector_HH',st+yearOffset,ed+yearOffset,fileExt,pth);

t = DecDOY - GMTshift + 1;                          % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed +1 );                 % extract the requested period
if strcmp(upper(siteID),'YF')                       % skip every other half hour (hourly measurements)
    ind = ind(1:2:end);
end
t = t(ind);
TimeVector = TimeVector(ind);

fig = 0;

%Site temperature stats
try
fig = fig+1;figure(fig);clf
    traceName = 'stats.Chambers.Climate_Stats.temp_air(:,4)';
[DecDOY,x1] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
   traceName = 'stats.Chambers.Climate_Stats.temp_soil(:,4)';
[DecDOY,x2] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x1(ind,:),'b');
hold on;
plot(t,x2(ind,:),'r');
hold off;
legend('Air T','Soil T 2cm');
axis([t(1) t(end) -40 30]);grid on;zoom on;
xlabel('DOY')
title('Air and soil temperature')
ylabel('C')
catch
close
end

%Licor co2 stats
try
fig = fig+1;figure(fig);clf
traceName = 'stats.Chambers.Diagnostic_Stats.co2_avg(:,[1:3])';
[DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));
axis([t(1) t(end) 0 1000]);
grid on;zoom on;
xlabel('DOY')
title('Licor CO2 (avg, min, max)')
ylabel('ppm')
catch
close
end

%Licor cell temperature stats
try
fig = fig+1;figure(fig);clf
traceName = 'stats.Chambers.Diagnostic_Stats.temp_avg(:,[1:3])';
[DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));
axis([t(1) t(end) 20 40]);
grid on;zoom on;
xlabel('DOY')
title('Licor cell temperature (avg, min, max)')
ylabel('C')
catch
close
end

%Licor cell pressure stats
try
fig = fig+1;figure(fig);clf
traceName = 'stats.Chambers.Diagnostic_Stats.press_avg(:,[1:3])';
[DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));
axis([t(1) t(end) 60 90]);
grid on;zoom on;
xlabel('DOY')
title('Licor cell pressure (avg, min, max)')
ylabel('kPa')
catch
close
end

%battery voltage stats
try
fig = fig+1;figure(fig);clf
traceName = 'stats.Chambers.Diagnostic_Stats.batt_vol(:,1)';
[DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));
axis([t(1) t(end) 11 15]);
grid on;zoom on;
xlabel('DOY')
title('battery voltage')
ylabel('V')
catch
close
end

%control and pumpbox stats
try
fig = fig+1;figure(fig);clf
traceName1 = 'stats.Chambers.Diagnostic_Stats.ctrbox_temp(:,1)';
[DecDOY,x1] = ach_join_trace(traceName1,st+yearOffset,ed+yearOffset,fileExt,pth);
traceName2 = 'stats.Chambers.Diagnostic_Stats.pumpbox_temp(:,1)';
[DecDOY,x2] = ach_join_trace(traceName2,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x1(ind,:),'g');
hold on;
plot(t,x2(ind,:),'b');
hold off;
axis([t(1) t(end) -20 40]);
grid on;zoom on;
legend('control box','pump box');
xlabel('DOY')
title('control and pumpbox temperatures')
ylabel('C')
catch
close
end

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

%site specific chamber operation
if siteID == 'PA';
   traceName_ev = 'stats.Chambers.Fluxes_Stats.evOutLong.ev(:,[1:8])';
   traceName_fluxes = 'stats.Chambers.Fluxes_Stats.fluxOutLong.flux(:,[1:8])';
   legendTmp = ['ch1';'ch2';'ch3';'ch4';'ch5';'ch6';'ch7';'ch8'];
   chNbr = 8;
elseif siteID == 'BS' 
   % flags describing current chamber config at SOBS: Nick added May 15,
   % 2008
   winter_mode = 0;
   branch_ch = 0;
   rt_excl = 1;
   if winter_mode
     traceName_ev = 'stats.Chambers.Fluxes_Stats.evOutLong.ev(:,[5:7 9:11])';
     traceName_fluxes = 'stats.Chambers.Fluxes_Stats.fluxOutLong.flux(:,[5:7 9:11])';
     legendTmp = ['ch05';'ch06';'ch07';'ch09';'ch10';'ch11'];
     chNbr = 6;
   else
     traceName_ev = 'stats.Chambers.Fluxes_Stats.evOutLong.ev(:,[1:12])';
     traceName_fluxes = 'stats.Chambers.Fluxes_Stats.fluxOutLong.flux(:,[1:12])';
     legendTmp = ['ch01';'ch02';'ch03';'ch04';'ch05';'ch06';'ch07';'ch08';'ch09';'ch10';'ch11';'ch12'];
     chNbr = 12;
  end
elseif siteID == 'JP'
   traceName_ev = 'stats.Chambers.Fluxes_Stats.evOutLong(:,[1:6])';
   traceName_fluxes = 'stats.Chambers.Fluxes_Stats.fluxOutLong.flux(:,[1:6])';
   legendTmp = ['ch1' ;'ch2';'ch3';'ch4';'ch6'];
   chNbr = 6;
elseif siteID == 'YF'
   traceName_ev = 'stats.Chambers.Fluxes_Stats.evOutLong.ev(:,[1:6])';
   traceName_fluxes = 'stats.Chambers.Fluxes_Stats.fluxOutLong.flux(:,[1:6])';
   legendTmp = ['ch01';'ch02';'ch03';'ch04';'ch05';'ch06'];
   chNbr = 6;
end

%effective volumes stats
try
fig = fig+1;figure(fig);clf
traceName = traceName_ev;
[DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:).*1000);
axis([t(1) t(end) 0 100]);
grid on;zoom on;
legend(legendTmp);
xlabel('DOY');
title('effective volumes');
ylabel('litres');
catch
close
end

%fluxes stats
try
    if siteID == 'BS'    
        fig = fig+1;figure(fig);clf
        traceName = traceName_fluxes;
        [DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
        
        if ~winter_mode 
          if branch_ch
           plot(t,x(ind,1:6));
           hold on;
           plot(t,x(ind,7),'bo-');
           plot(t,x(ind,8),'yx-');
           plot(t,x(ind,9:12));
           hold off;
          else
           %plot(t,x(ind,1:12)); % chamber 8 is currently not in use; Nick 20080603
           plot(t,x(ind,[1:7 9:12]));
           legendTmp = ['ch01';'ch02';'ch03';'ch04';'ch05';'ch06';'ch07';'ch09';'ch10';'ch11';'ch12'];
          end
        end
        plot(t,x(ind,[1:6]));
        axis([t(1) t(end) -1 10]);
        grid on;zoom on;
        legend(legendTmp);
        xlabel('DOY');
        title('CO2 fluxes');
        ylabel('\mumol m^{-2} s^{-1}');
    else
        fig = fig+1;figure(fig);clf
        traceName = traceName_fluxes;
        [DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
        plot(t,x(ind,:));
        axis([t(1) t(end) -1 10]);
        grid on;zoom on;
        legend(legendTmp);
        xlabel('DOY');
        title('CO2 fluxes');
        ylabel('\mumol m^{-2} s^{-1}');
    end
catch
    close
end

%root exclusion + branch + bole chambers for SOBS
if siteID == 'BS' & ~winter_mode
    
    if branch_ch
        try
            %load Fc from eddy covariance
            pth_berms = '\\paoa001\Sites\PAOB\hhour\';fileExt_berms = 's.hb.mat';
            traceName = 'stats.Fluxes.LinDtr(:,[5])';
            [DecDOY_site,Fc] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt_berms,pth_berms);
            fig = fig+1;figure(fig);clf
            %load photosynthesis from branch chamber
            traceName = traceName_fluxes;
            [DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
            Fbranch = x(ind,8);
            Fbranch = Fbranch .* 3.8; %scale up using LAI for the site


            plot(t,Fbranch,'y');
            hold on;
            plot(t,Fc(ind,:),'b');
            hold off;
            axis([t(1) t(end) -30 10]);
            grid on;zoom on;
            legend('Scaled-up photosynthesis branch chamber','Fc eddy covariance');
            legend boxoff;
            xlabel('DOY');
            title('CO2 fluxes');
            ylabel('\mumol m^{-2} ground s^{-1}');
        catch
            disp('Failed in chamber_pl: branch + bole chambers for SOBS');
            close
        end
    end
    
    if rt_excl
        try
            fig = fig+1;figure(fig);clf
            traceName = traceName_fluxes;
            [DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
            plot(t,x(ind,3),'r-.');
            hold on;
            plot(t,x(ind,9),'g-.');
            plot(t,x(ind,12),'c-.');
            plot(t,x(ind,4),'r-','LineWidth',1.5);
            plot(t,x(ind,10),'g-','LineWidth',1.5);
            plot(t,x(ind,11),'c-','LineWidth',1.5);
            hold off;
            legend('ch3','ch9','ch12','ch4','ch10','ch11');
            axis([t(1) t(end) -1 10]);
            grid on;zoom on;
            xlabel('DOY');
            title('Root exclusion experiment');
            ylabel('\mumol m^{-2} s^{-1}');
        catch
            close
        end

        try
            fig = fig+1;figure(fig);clf
            traceName = traceName_fluxes;
            [DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
            Rhr = (x(ind,4) + x(ind,10) + x(ind,11)) ./3 ;  %control plots
            Rh = (x(ind,3) + x(ind,9) + x(ind,12)) ./3 ;   %root excluded plots
            % Rhr = (x(ind,3) + x(ind,6)) ./2 ;  %control plots
            % Rh = (x(ind,4) + x(ind,5)) ./2 ;   %root excluded plots
            Rr = Rhr - Rh;
            plot(t,Rhr,'b');
            hold on;
            plot(t,Rh,'r');
            plot(t,Rr,'g');
            hold off;

            legend('Control','Root-exclusion','Control - Root-exclusion');
            axis([t(1) t(end) -1 10]);
            grid on;zoom on;
            xlabel('DOY');
            title('Root exclusion experiment');
            ylabel('\mumol m^{-2} s^{-1}');
        catch
            close
        end

        try
            fig = fig+1;figure(fig);clf
            traceName = traceName_fluxes;
            [DecDOY,x] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
            ratio = Rh./Rhr;
            plot(t,ratio,'b');
            axis([t(1) t(end) 0 1.2]);
            grid on;zoom on;
            xlabel('DOY');
            title('Root exclusion experiment');
            ylabel('ratio heterotrophic/total respiration');
        catch
            close
        end

        try
            fig = fig+1;figure(fig);clf
            traceName = 'stats.Chambers.Climate_Stats.vwc(:,[7 10])';
            [DecDOY,x1] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
            traceName = 'stats.Chambers.Climate_Stats.vwc(:,[8 9])';
            [DecDOY,x2] = ach_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
            plot(t,x1(ind,:),'b');
            hold on;
            plot(t,x2(ind,:),'r');
            hold off;
            legend('VWC Control1','VWC Control2','VWC Rootexcluded1','VWC Rootexcluded2');
            axis([t(1) t(end) 0 0.4]);
            grid on;zoom on;
            xlabel('DOY');
            title('Root exclusion experiment');
            ylabel('m^3 m^{-3}');
        catch
            close
        end
    end
    
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
        plot(t_temp,temp);
        axis([t_temp(1) t_temp(end) 0 35]);
        datetick('x',15);
        legend('Outside air','Inside air 1','Inside air 2','Inside air 3','PC inside','PC outside','Wall 1','Wall 2');
        legend boxoff;
        grid on;zoom on;
        xlabel('DOY')
        title('High-freq. branch chamber temperature measurements (last day of requested period)');
        ylabel('^oC');
        
        fig = fig+1;figure(fig);clf
        subplot(3,1,1);
        plot(t_temp,climCtrl(:,1));
        axis([t_temp(1) t_temp(end) 0 100]);
        datetick('x',15);
        legend('RH inside branch chamber');
        legend boxoff;
        grid on;zoom on;
        xlabel('DOY')
        title('High-freq. RH measurements for branch chamber (last day of requested period)');
        ylabel('%');
        
        subplot(3,1,2);
        plot(t_temp,climCtrl(:,2));
        hold on;
        plot(t_temp,climCtrl(:,7));
        hold off;
        axis([t_temp(1) t_temp(end) -10 1500]);
        datetick('x',15);
        legend('PAR inside branch chamber','RunAvg PAR inside branch chamber');
        legend boxoff;
        grid on;zoom on;
        xlabel('DOY')
        title('High-freq. PAR measurements inside branch chamber (last day of requested period)');
        ylabel('%');
        
        subplot(3,1,3);
        plot(t_temp,climCtrl(:,3));
        hold on;
        plot(t_temp,climCtrl(:,4));
        plot(t_temp,climCtrl(:,5));
        plot(t_temp,climCtrl(:,6));
        plot(t_temp,climCtrl(:,8));
        plot(t_temp,climCtrl(:,9));   
        hold off;
        axis([t_temp(1) t_temp(end) 0 35]);
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
