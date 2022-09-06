function x = eddy_pl(DOYs,year,siteID,select)
%
% x = eddy_pl(DOYs,year,siteID)
%
%   This function plots selected data from the eddy-flux files. It reads from
%   the short form hhour files.
%
%
% (c) Nesic Zoran           File created:       Jun 12, 1998
%                           Last modification:  Aug  2, 2004
%

% Revisions:
%   Aug 3, 2006
%       -changed RMYoung trace location to BERMS\al1 from BERMS\all
%        for OBS in first plot--al1 file updated more frequently by MSC (Nick)
%   Dec 22, 2005
%       - commented out H2O and CO2 calibration plots
%   Aug 2, 2004
%       - moved fluxes to diagnostic plots
%   May 11, 2004
%       - added histogram of CO2 and H2O delay times
%   Nov 26, 2003
%       - introduced the EC/Profile and 3-BERMS-sites comparison for CO2
%   May 2, 2003
%       - moved CO2 and H20 concentration value plots to "Diagnostic" section
%   Aug 26, 2002
%       - added air temps and delay times to the diagnostic section
%   Feb 2, 2002 
%       - brought diagnostic info up front and isolate with 'select'
%   Nov 23, 2001
%       - added plotting of some sigmas (w, T, C, H)
%   Jul 27, 2001
%       - added plotting of the profile system
%   May 17, 2001
%       - fixing up a few minor bugs
%   May 16, 2001
%       - added delay time plots using the setup data
%   Aug  9, 2000
%       - added RMYoung traces to the wind speed plot
%       - removed all Krypton plots
%   Jan 24, 2000
%       - added Licor6262 pressure to the plots
%   September 10, 1999
%       - added Campbell Sonic at 2.5-m height
%   Jul 5, 1999
%       - axes changes
%	May 12, 1999
%       - changed some axis
%   Apr 26, 1999
%       - included corrections needed for OBS and OJP
%   Mar 28, 1999
%       - adjusted H2O axes 
%   Jan 18, 1999
%       - adjusted some axes
%   Jan 11, 1999
%       - changed axes for most of the plots (they are now fixed).
%   Jan 1, 1999
%       - changes to alow for the new year (1999). The changes enabled
%         automatic handling of the "year" parameter.
%   Jul 19, 1998
%       - fixed local path and removed min. and max. plots of U_wind
%
LOCAL_PATH = 0;

colordef none
pos = get(0,'screensize');
set(0,'defaultfigureposition',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);      % universal

if ~exist('siteID') | isempty(siteID)
    siteID = 'BS';
end
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

switch upper(siteID)
    case 'CR',GMTshift = 8/24;
    case {'PA','BS','JP'},GMTshift = 6/24;
end
if year >= 1998
    if LOCAL_PATH == 1
        pth = 'd:\met-data\hhour\';fileExt = 's.hb.mat';
    else
        switch upper(siteID)
            case 'CR',pth = '\\paoa001\Sites\cr\hhour\';fileExt = 's.hc.mat';
            case 'PA',pth = '\\paoa001\Sites\paoa\hhour\';fileExt = 's.hp.mat';
            case 'BS',pth = '\\paoa001\Sites\PAOB\hhour\';fileExt = 's.hb.mat';
            case 'JP',pth = '\\paoa001\Sites\PAOJ\hhour\';fileExt = 's.hj.mat';
        end
        
    end
else
    error 'Data for the requested year is not available!'
end

st = min(DOYs);                                      % first day of measurements
ed = max(DOYs);                                    % last day of measurements (approx.)

yearOffset = datenum(year,1,1,0,0,0)-1;
[DecDOY,TimeVector] = fr_join_trace('stats.TimeVector',st+yearOffset,ed+yearOffset,fileExt,pth);

t = DecDOY - GMTshift + 1;                          % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed +1 );                  % extract the requested period
t = t(ind);
TimeVector = TimeVector(ind);

fig = 0;
%-----------------------------------------------
% Gill wind speed (after rotation)
%
fig = fig+1;figure(fig);clf
pthClim = biomet_path(year,siteID,'cl');      % get the climate data path
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,[1 2 ],:))';
        ini_climMain = fr_get_logger_ini('cr',year,'fr_clim','fr_clim_105');   % main climate-logger array
        RMYoung = read_bor(fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_AVG', pthClim));
%        t_RMYoung = read_bor([pthClim 'fr_a\fr_a_tv'],8)-yearOffset-GMTshift;
        t_RMYoung = read_bor(fr_logger_to_db_fileName(ini_climMain, '_tv', pthClim),8)-yearOffset-GMTshift;                               % get decimal time from the data base
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,[14 16 12],:))';
        switch upper(siteID)
            case 'PA'
                RMYoung = read_bor([pthClim 'bonet_new\bntn.48']);
                t_RMYoung = read_bor([pthClim 'bonet_new\bntn_tv'],8)-yearOffset-GMTshift;
            case 'BS'
                pthBERMS = biomet_path(year,siteID,'BERMS\al1');
                try
                    RMYoung = read_bor([pthBERMS 'Wind_Spd_AbvCnpy_26m']);
                    t_RMYoung = read_bor([pthBERMS 'clean_tv'],8)-yearOffset-GMTshift;
                catch
                    RMYoung = NaN .* ones(size(t));
                    t_RMYoung = t;
                end
            otherwise,
                RMYoung = [];
                t_RMYoung = [];
        end
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
%plot(t,x(ind,1),t,max(x_max(ind,:)'.^2).^0.5',t,min(x_min(ind,:)'.^2).^0.5');grid on;zoom on;xlabel('DOY')
indRMYoung = find(t_RMYoung >= t(1) & t_RMYoung <= t(end));
plot(t,x(ind,1),t_RMYoung(indRMYoung),RMYoung(indRMYoung));
grid on;
zoom on;
xlabel('DOY')
axis([t(1) t(end) 0 10])
title('Gill wind speed (after rotation)');
ylabel('U (m/s)')
legend('Sonic','RMYoung')

%-----------------------------------------------
% Air temperatures (Gill and 0.001" Tc)
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,[4 8 9],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,[13 3 4],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
title('Air temperatures (Gill and 0.001" Tc)')
ylabel('\circC')
legend('Gill','Tc',-1)

%-----------------------------------------------
% Gauge pressure
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[15],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[10],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')

%xx=x(ind);xx(end-50:end)=xx(end-50:end) +sin(linspace(0,4*pi,51))'*20;plot(t,xx);grid on;zoom on;xlabel('DOY')

axis([t(1) t(end) 0 22])
title('Gauge pressure')
ylabel('kPa')

%-----------------------------------------------
% Licor pressure
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[14],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[9],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
%axis([t(1) t(end) 0 22])
title('Licor pressure')
ylabel('kPa')


%-----------------------------------------------
% Barometric pressure
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[25],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[20],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
title('Barometric pressure')
ylabel('kPa')

%-----------------------------------------------
% Reference cell pressure
%
if 1==0
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[16],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[11],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
title('Reference cell pressure')
ylabel('kPa')
end

%-----------------------------------------------
% Optical bench temperature
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[13],:))';ax=[24 38];
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[8],:))';ax=[36 42];
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')

%xx=x(ind);xx(end-100:end)=28 +[linspace(0,20,51)'; -0.2*linspace(0,20,50)'];plot(t,xx);grid on;zoom on;xlabel('DOY')

axis([t(1) t(end) ax])
title('Optical bench temperature')
ylabel('\circC')

%-----------------------------------------------
% Optical bench temperature for  Profile licor
%
try
    fig = fig+1;figure(fig);clf
    traceName = 'stats.Profile.Tbench.Avg(:,1)';ax=[36 42];
    [DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
    plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
    axis([t(1) t(end) ax])
    title('Optical bench temperature - Profile System')
    ylabel('\circC')
catch
    close(fig);
    fig=fig-1;
end
%-----------------------------------------------
% Pgauge for  Profile licor
%
try
    fig = fig+1;figure(fig);clf
    traceName = 'stats.Profile.Pgauge.Avg';
    [DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
    plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
    axis([t(1) t(end) -Inf Inf])
    title('Gauge pressure - Profile System')
    ylabel('kPa')
catch
    close(fig);
    fig=fig-1;
end

%-----------------------------------------------
% Licor pressure for  Profile licor
%
try
    fig = fig+1;figure(fig);clf
    traceName = 'stats.Profile.Plicor.Avg';
    [DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
    plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
    axis([t(1) t(end) -Inf Inf])
    title('Licor Pressure - Profile System')
    ylabel('kPa')
catch
    close(fig);
    fig=fig-1;
end

%-----------------------------------------------
% H_2O (mmol/mol of dry air)
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[12],:))';ax=[-1 22];
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[7],:))';ax=[-1 22];
end
[DecDOY,h2o_eddy] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,h2o_eddy(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) ax])
title('H_2O ')
ylabel('(mmol mol^{-1} of dry air)')

% Figure below commented out becasue it is confusing
% fig = fig+1;figure(fig);clf
% plot(t,h2o_eddy(ind,:),'o-');grid on;zoom on;xlabel('DOY')
% axis([t(1) t(end) -.3 .3])
% title('H_2O Calibrations')
% ylabel('(mmol mol^{-1} of dry air)')

%-----------------------------------------------
% CO_2 (\mumol mol^-1 of dry air)
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[11],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(1:3,[6],:))';
end
[DecDOY,co2_eddy] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,co2_eddy(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) 340 420])
title('CO_2')
ylabel('\mumol mol^{-1} of dry air')

% Figure below commented out because the figure it is confusing
% fig = fig+1;figure(fig);clf
% plot(t,co2_eddy(ind,:),'o-');grid on;zoom on;xlabel('DOY')
% axis([t(1) t(end) -3 3])
% title('CO_2 calibrations')
% ylabel('\mumol mol^{-1} of dry air')

%-----------------------------------------------
% CO_2 profile
%
try
    fig = fig+1;figure(fig);clf
    traceName = 'stats.Profile.co2.Avg';
    [DecDOY,co2_profile] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
    plot(t,co2_profile(ind,:));grid on;zoom on;xlabel('DOY')
    axis([t(1) t(end) -Inf Inf])
    title('CO_2 profile')
    ylabel('ppm')
    
    fig = fig+1;figure(fig);clf
    plot(t,co2_eddy(ind,1),t,co2_profile(ind,end));grid on;zoom on;xlabel('DOY')
	 legend('Eddy','Profile',4)
    axis([t(1) t(end) 300 400])
    title('Comparison CO_2 profile vs. eddy')
    ylabel('ppm')
catch
    close(fig);
    fig=fig;
end

try
switch upper(siteID)
case {'PA','BS','JP'}
   SiteIDs = {'PA','BS','JP'};
   fig = fig+1;figure(fig);clf
   for i = 1:3
        switch upper(char(SiteIDs(i)))
            case 'PA',pth_berms = '\\paoa001\Sites\paoa\hhour\';fileExt_berms = 's.hp.mat';
            case 'BS',pth_berms = '\\paoa001\Sites\PAOB\hhour\';fileExt_berms = 's.hb.mat';
            case 'JP',pth_berms = '\\paoa001\Sites\PAOJ\hhour\';fileExt_berms = 's.hj.mat';
        end
      %char
      traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,[6],:))';
      [DecDOY_site,co2_site] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt_berms,pth_berms);
        if ~isempty(DecDOY_site)
            DecDOY = DecDOY_site;
            co2(:,i) = co2_site;
        end
   end
   plot(t,co2(ind,:));grid on;zoom on;xlabel('DOY')
   axis([t(1) t(end) 340 420]);
   title('CO_2 at the three BERMS sites')
   ylabel('\mumol mol^{-1} of dry air')
   legend(SiteIDs)
end
end

%-----------------------------------------------
% CO_2 & H_2O delay times
%
fig = fig+1;figure(fig);clf
[DecDOY,x] = fr_join_trace('stats.Misc(:,[11:12])',st+yearOffset,ed+yearOffset,fileExt,pth);
c = fr_get_init(siteID,ed+yearOffset);
plot(t,x(ind,:),'o')
h = line([t(1) t(end)],c.Delays.All(6+c.GillR2chNum)*ones(1,2));
set(h,'color','y','linewidth',1.5)
h = line([t(1) t(end)],c.Delays.All(7+c.GillR2chNum)*ones(1,2));
set(h,'color','m','linewidth',1.5)
grid on;zoom on;xlabel('DOY')
title('CO_2 & H_2O delay times')
ylabel('Samples')
legend('CO_2','H_2O','CO_2 setup','H_2O setup',-1)

%-----------------------------------------------
% CO_2 & H_2O delay times (Histogram)
%
fig = fig+1;figure(fig);clf
subplot(2,1,1)
hist(x(ind,1),200)
ax=axis;
h = line(c.Delays.All(6+c.GillR2chNum)*ones(1,2),ax(3:4));
set(h,'color','y','linewidth',2)
ylabel('CO_2 delay times')
subplot(2,1,2)
hist(x(ind,2),200)
ax=axis;
h = line(c.Delays.All(7+c.GillR2chNum)*ones(1,2),ax(3:4));
set(h,'color','y','linewidth',2)
ylabel('H_2O delay times')
zoom_together(gcf,'x','on')

%-----------------------------------------------
% CO2 flux
%
fig = fig+1;figure(fig);clf
traceName = 'stats.Fluxes.LinDtr(:,[5])';
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) -30 10])
title('F_c')
ylabel('\mumol m^{-2} s^{-1}')

%-----------------------------------------------
% Sensible heat
%
fig = fig+1;figure(fig);clf
traceName = 'stats.Fluxes.LinDtr(:,[2 3 4])';
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) -200 600])
title('Sensible heat')
ylabel('(Wm^{-2})')
legend('Gill','Tc1','Tc2',-1)


%-----------------------------------------------
% Hgill vs Htc
%
fig = fig+1;figure(fig);clf
x1=x(:,1);
x2=x(:,2);
p=polyfit(x1,x2,1);
if p(1)<0.5
    x2=x(:,3);
    p=polyfit(x1,x2,1);
end
[p,x1,x2] = polyfit_plus(x1,x2,1);
plot(x1,x2,'.',x1,polyval(p,x1),x1,x1);grid on;zoom on;xlabel('H Gill')
axis([-200 400 -200 400])
title('Gill vs Thermocouple 1:1')
ylabel('H Thermocouple')
text(120,20,sprintf('Tc = %f Gill + (%f)',p),'fontsize',10);




%------------------------------------------
if select == 1 %diagnostics only
    childn = get(0,'children');
    childn = sort(childn);
    N = length(childn);
    for i=childn(:)';
        if i < 200 
            figure(i);
%            if i ~= childn(N-1)
                pause;
%            end
        end
    end
    return
end

%-----------------------------------------------
% SigmaW (Gill)
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[3],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[12],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) 0  3])
title('\sigma_w (Gill)')
ylabel('m s^{-1}')
%legend('Gill','Tc',-1)


%-----------------------------------------------
% SigmaT (Gill and 0.001" Tc)
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[4 8 9],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[13 3 4],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
title('\sigma_T (Gill and 0.001" Tc)')
axis([t(1) t(end) 0  3])
ylabel('\circC')
legend('Gill','Tc',-1)



%-----------------------------------------------
% sigma H_2O (mmol/mol of dry air)
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[12],:))';ax=[-1 22];
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[7],:))';ax=[-1 22];
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) 0  1])
title('\sigma_{H_2O} ')
ylabel('(mmol mol^{-1} of dry air)')


%-----------------------------------------------
% Sigma CO_2 (\mumol mol^-1 of dry air)
%
fig = fig+1;figure(fig);clf
switch upper(siteID)
   case 'CR',traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[11],:))';
   case {'PA','BS','JP'},traceName = 'squeeze(stats.AfterRot.AvgMinMax(4,[6],:))';
end
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) 0  3])
title('\sigma_{CO_2}')
ylabel('\mumol mol^{-1} of dry air')



%-----------------------------------------------
% Licor vs Krypton
%
fig = fig+1;figure(fig);clf
% traceName = 'stats.Fluxes.LinDtr(:,[1 6])';
traceName = 'stats.Fluxes.LinDtr(:,[1])';
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
axis([t(1) t(end) -100 400])
%title('Licor vs Krypton')
title('Licor')
ylabel('\lambdaE (Wm^{-2})')
%legend('LI-COR','Krypton',-1)

if 1==0
%-----------------------------------------------
% Licor vs Krypton 1:1
%
fig = fig+1;figure(fig);clf
x1=x(:,1);
x2=x(:,2);
[p,x1,x2] = polyfit_plus(x1,x2,1);
plot(x1,x2,'.',x1,polyval(p,x1),x1,x1);grid on;zoom on;xlabel('\lambdaE LI-COR')
axis([-100 300 -100 +300])
title('Licor vs Krypton 1:1')
ylabel('\lambdaE Krypton')
text(120,5,sprintf('KH_2O = %f LI-COR + (%f)',p),'fontsize',10);
end



%-----------------------------------------------
% H_2O profile
%
try
    fig = fig+1;figure(fig);clf
    traceName = 'stats.Profile.h2o.Avg';
    [DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
    plot(t,x(ind,:));grid on;zoom on;xlabel('DOY')
    axis([t(1) t(end) -Inf Inf])
    title('H_2O profile')
    ylabel('mmol/mol')

    fig = fig+1;figure(fig);clf
    plot(t,h2o_eddy(ind,1),t,x(ind,end));grid on;zoom on;xlabel('DOY')
	 legend('Eddy','Profile',4)
    axis([t(1) t(end) 0 30])
    title('Comparison H_2O profile vs. eddy')
    ylabel('mmol/mol')
catch
    close(fig);
    fig=fig-1;
end


if siteID == 'CR'
%-----------------------------------------------
% Closure
%
EBax = [-200 800];

fig = fig+1;figure(fig);clf
traceName = 'stats.Fluxes.LinDtr(:,[1 2])';
[DecDOY,x] = fr_join_trace(traceName,st+yearOffset,ed+yearOffset,fileExt,pth);
Rn = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Net_cnr1_AVG', pthClim));
t_clim = read_bor(fr_logger_to_db_fileName(ini_climMain, '_tv', pthClim),8)-yearOffset-GMTshift; 
indclim = find(t_clim >= t(1) & t_clim <= t(end));
plot(t_clim(indclim),Rn(indclim),t,x(ind,:));
grid on;zoom on;xlabel('DOY')
set(gca,'XLim', [t(1) t(end)], 'YLim', EBax);
title('Energy budget Closure')
ylabel('(Wm^{-2})')
legend('Rn','LE','H',-1);

fig = fig+1;figure(fig);clf
plot(t_clim,Rn,t,x(ind,1)+x(ind,2));
grid on;zoom on;xlabel('DOY')
set(gca,'XLim', [t(1) t(end)], 'YLim', EBax);
title('Energy budget Closure')
ylabel('(Wm^{-2})')
legend('Rn','LE+H',-1);

A = Rn(indclim);
T = x(ind,1)+x(ind,2);
[C,IA,IB] = intersect(datestr(t_clim(indclim)),datestr(t),'rows');
A = A(IA);
T = T(IB);
cut = find(isnan(A) | isnan(T) | A > 800 | A < -200 | T >800 | T < -200 | A == 0 | T == 0 );
A = clean(A,1,cut);
T = clean(T,1,cut);
[p, R2, sigma, s, Y_hat] = polyfit1(A,T,1);

fig = fig+1;figure(fig);clf;
plot(A,T,'.',...
   EBax,EBax,...
   EBax,polyval(p,EBax),'--');
text(-100, 400, sprintf('T = %2.3fA + %2.3f, R2 = %2.3f',p,R2));
xlabel('Rn (W/m2)');
ylabel('H+LE (W/m2)');
title('Energy budget');
h = gca;
set(h,'YLim',EBax,'XLim',EBax);
grid on;zoom on;

end

if 1==0
%-----------------------------------------------
% Krypton delay time
%
try,
[DecDOY,x] = fr_join_trace('stats.Misc(:,[17])',st+yearOffset,ed+yearOffset,fileExt,pth);
fig = fig+1;figure(fig);clf
plot(t,x(ind,:),'o');grid on;zoom on;xlabel('DOY')
title('Krypton delay time')
ylabel('Samples')
catch,
end
end


%-----------------------------------------------
% Campbell Sonic cup wind speed and air temperature
% (at 2.5-m height)

if siteID == 'CR'
   try,
   [t, cup3D_CSAT, cup3D_Gill, Tair_CSAT, Tair_Gill] = csat3_pl(st+yearOffset,ed+yearOffset);
	fig = fig+1;figure(fig);clf
   plot(t,cup3D_CSAT, t, cup3D_Gill);grid on;zoom on;xlabel('DOY')
   title('3D-cup wind speed (CSAT3 and Gill)')
   ylabel('u_{cup} (m s^{-1})')
   legend('CSAT3 (2.5 m)', 'Gill (42.7 m))')
catch,
end

try,
   [t, cup3D_CSAT, cup3D_Gill, Tair_CSAT, Tair_Gill] = csat3_pl(st+yearOffset,ed+yearOffset);
   fig = fig+1;figure(fig);clf
   plot(t,Tair_CSAT, t, Tair_Gill);grid on;zoom on;xlabel('DOY')
   title('Air temperatures (CSAT3 and Gill)')
   ylabel('T_{air} (\circ C)')
   legend('CSAT3 (2.5 m)', 'Gill (42.7 m))')
catch,
end
end

%N=max(get(0,'children'));
%for i=1:N;
%    figure(i);
%    if i~= N,pause;end;
%end

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



%========================================================
% local functions

function [p,x1,x2] = polyfit_plus(x1in,x2in,n)
    x1=x1in;
    x2=x2in;
    tmp = find(abs(x2-x1) < 0.5*abs(max(x1,x2)));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
    diffr = x2-polyval(p,x1);
    tmp = find(abs(diffr)<3*std(diffr));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
    diffr = x2-polyval(p,x1);
    tmp = find(abs(diffr)<3*std(diffr));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
