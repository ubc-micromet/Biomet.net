function [chamber_data] = ch_pl_hhour(x,SiteID);
% Program that defines paths to retrieve comma delimited files for old chamber system (PA and BS) and 
% where to read (and/or put) binary files
%
% Created by Zoran Nesic
%
% Revisions:
%  - Aug. 12, 2002, created a new program (ch_pl_hhour_new (called within ch_pl)) to allow plotting of JP 
%  system. Needed this because of the new data structure (David)
%  - Nov. 19, 2001, added figure ratio effective/real volume (David)
% -------------------------------------------------------------------------

WINTER_TEMPERATURE_OFFSET = 10;
 
if exist('x')~= 1 | isempty(x)
    error 'Input data structure is missing!'
end

t1       =  x.Chambers.Time_vector_HF_short;
t1_ind   =  x.Chambers.Time_ind;
t        = interp1(t1_ind,t1,t1_ind(1):t1_ind(end));    
Dec_day  = fr_get_doy(t,0);

%------------------------------------------------------------------------------------

close all
fig = 1;

N = length(x.Chambers.CO2_HF_short);

% plot CO2 HF trace

figure(fig);
plot(t, x.Chambers.CO2_HF_short);
datetick('x',15);
zoom on
grid on
title('High-freq. CO2 measurements');
xlabel('Time');
ylabel('ppm');
tmp=get(gcf,'WindowButtonDownFcn');
set(gcf,'WindowButtonDownFcn',[tmp ';datetick1(''x'',15) ;']);

% compute and plot effective volume

[ev_1, ev_2] = ch_effective_volume(t,x.Chambers.CO2_HF_short,SiteID);

fig=fig+1;
figure(fig);
plot(ev_1(1:10:51),'o');
hold on;
plot(ev_2(1:10:51),'*');
hold off;
legend('midnight calibration','noon calibration');
title('Effective volume');
ylabel('ev (litres)');
xlabel('Chamber number');
axis([1 6 0 150]);
grid on
zoom on    

% ---

A = fr_get_doy(x.Chambers.TimeVectorHH_21x,0);

% plot fluxes

fig=fig+1;
figure(fig);
plot(A, x.Chambers.Fluxes_Stats.fluxes);
datetick('x',15);
zoom on
grid on
title('CO2 fluxes calculated at the site');
xlabel('Time');
ylabel('\mumol m^{-2} s^{-1}');
legend('1','2','3','4','5','6')
tmp=get(gcf,'WindowButtonDownFcn');
set(gcf,'WindowButtonDownFcn',[tmp ';datetick1(''x'',15) ;']);

% plot licor and platform stats

fig=fig+1;
figure(fig);
plot(A, x.Chambers.Diagnostic_Stats.co2_avg(:,1),A, x.Chambers.Diagnostic_Stats.co2_avg(:,2),A, x.Chambers.Diagnostic_Stats.co2_avg(:,3));
title('CO2 Stats');
zoom on
grid on

fig = fig+1;
figure(fig);
plot(A, x.Chambers.Diagnostic_Stats.temp_avg(:,1),A, x.Chambers.Diagnostic_Stats.temp_avg(:,2),A, x.Chambers.Diagnostic_Stats.temp_avg(:,3));
title('Licor temperature Stats');
zoom on
grid on

fig = fig+1;
figure(fig);
plot(A, x.Chambers.Diagnostic_Stats.press_avg(:,1),A, x.Chambers.Diagnostic_Stats.press_avg(:,2),A, x.Chambers.Diagnostic_Stats.press_avg(:,3));
title('Licor pressure Stats');
zoom on
grid on

fig = fig+1;
figure(fig);
plot(A, x.Chambers.Diagnostic_Stats.mfc_avg(:,1),A, x.Chambers.Diagnostic_Stats.mfc_avg(:,2),A, x.Chambers.Diagnostic_Stats.mfc_avg(:,3));
title('MFC Stats');
zoom on
grid on

fig = fig+1;
figure(fig);
plot(A, x.Chambers.Diagnostic_Stats.batt_vol(:,1));
axis([-inf inf 9.5 14.5]);
title('battery voltage');
xlabel('DDOY');
ylabel('voltage');
zoom on
grid on

fig = fig+1;
figure(fig);
plot(A, x.Chambers.Diagnostic_Stats.ctrbox_temp(:,1), A, x.Chambers.Diagnostic_Stats.pumpbox_temp(:,1));
axis([-inf inf [10 50]]);
legend('Ctrl Box','Pump Box');
title('Box Temperatures');
zoom on
grid on

if 1==1
% plot chambers temperatures

for i = 1:6;
   fig = fig+1;
   figure(fig);
   plot(A, x.Chambers.Climate_Stats.temp_air(:,i),A, x.Chambers.Climate_Stats.temp_sur(:,i),A, x.Chambers.Climate_Stats.temp_2cm(:,i));
   axis([-inf inf [0 30]]);
   legend('Air temp','Surface temp','2cm temp');
   title('Chamber Temperatures');
   zoom on
   grid on
end

% plot PAR for BS

if (SiteID) == 'BS';
   try
    fig = fig+1;
    figure(fig);
    plot(A, x.Chambers.Climate_Stats.ppfd(:,1:3));
    axis([-inf inf -inf inf]);
    title('Photosynthetically Active Radiation')
    legend('Chamber 1','Chamber 2','Chamber 3')
    zoom on
    grid on
   end
end

end

N = max(get(0,'children'));

for i=1:N;
   figure(i);
   if i~=N
      pause;
   end
end

