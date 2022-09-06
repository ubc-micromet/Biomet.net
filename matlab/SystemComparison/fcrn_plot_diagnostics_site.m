function h = fcrn_plot_diagnostics_site(Stats_all,T_air,p_bar,Rn,WindDirection)
% h = fcrn_plot_diagnostics(Stats_all,T_air,p_bar,Rn,WindDirection)
%
% Diagnostic plots for the XSITE system 

T_air_sys = get_stats_field(Stats_all,'MiscVariables.Tair');
p_bar_sys = get_stats_field(Stats_all,'MiscVariables.BarometricP');
Rn_sys = NaN .* ones(size(T_air_sys));
WindDirection_sys = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');

arg_default('T_air',T_air_sys);
arg_default('p_bar',p_bar_sys);
arg_default('Rn',Rn_sys);
arg_default('WindDirection',WindDirection_sys);

plotting_setup

%----------------------------------------------------
% Define variables to be extracted for both systems
%----------------------------------------------------
% This is the list of diagnostic variables that are 
% common to both system
variable_info = [...
   {'MiscVariables.OrigNumOfSamples','N_org',' '}',...
   {'MiscVariables.NumOfSamples','N',' '}',...
   {'Delays.Calculated(1)','del_CO2','samples'}',...
   {'Delays.Calculated(2)','del_H2O','samples'}',...
   {'Avg(2)','H2O',' '}',...
   {'Avg(3)','T_licor','^oC'}',...
   {'Avg(4)','p_licor','kPa'}',...
];

% For plotting replace the underscore
variable_info(4,:) = strrep(variable_info(2,:),'_','\_');

%----------------------------------------------------
% Extract variables for both systems
%----------------------------------------------------
[var_names_cp] = fcrn_extract_var('Stats_all',{'MainEddy'},variable_info(:,1:5));
[var_names_in] = fcrn_extract_var('Stats_all',{'Instrument(5)'},variable_info(:,[5:7]));

dv = datevec(tv(1));
doy = tv - datenum(dv(1),1,0);
doy_ticks = [floor(doy(1)):1:ceil(doy(end))];

%----------------------------------------------------
% Calculate relative humidity
%----------------------------------------------------
es = sat_vp(T_air);
e  = p_bar .* ( H2O_Instrument_5./1000 ./ (1+H2O_Instrument_5./1000) );
r_h = e./es .* 100;

%----------------------------------------------------
% Do comparison plots
%----------------------------------------------------
fsize_txorg = get(0,'DefaultTextFontSize');
fsize_axorg = get(0,'DefaultAxesFontSize'); 
set(0,'DefaultAxesFontSize',10) 
set(0,'DefaultTextFontSize',10);

h(1).name = 'Diagnostics_Climate';
h(1).hand = figure;
set(h(1).hand,'Name',h(1).name);
set(h(1).hand,'NumberTitle','off');


% Net Radiation
subplot('Position',subplot_position(5,1,1));
plot(doy,Rn);
%subplot_label(gca,5,1,1,doy_ticks,yticks(Rn,100),2)
ylabel('Rn (W m^{-2})')

% Wind direction
subplot('Position',subplot_position(5,1,2));
plot(doy,WindDirection);
%subplot_label(gca,5,1,2,doy_ticks,0:60:360,2)
ylabel('Wind dir. (deg)')

% Relative humidity
subplot('Position',subplot_position(5,1,3));
plot(doy,r_h);
%subplot_label(gca,5,1,3,doy_ticks,yticks(r_h,20),2)
ylabel('r_h (%)')

% Pressures
subplot('Position',subplot_position(5,1,4));
plot(doy,[p_bar p_licor_Instrument_5]);
%subplot_label(gca,5,1,4,doy_ticks,yticks([p_bar;p_licor_Instrument_5],20),2)
ylabel('MainEddy p (kPa)')

% Temperatures
subplot('Position',subplot_position(5,1,5));
plot(doy,[T_air T_licor_Instrument_5]);
%subplot_label(gca,5,1,5,doy_ticks,yticks([T_air;T_licor_Instrument_5],5),2)
ylabel('MainEddy T (^oC)')

zoom_together(gcf,'x','on')

h(2).name = 'Diagnostics_MainEddy';
h(2).hand = figure;
set(h(2).hand,'Name',h(2).name);
set(h(2).hand,'NumberTitle','off');

% Number of samples
subplot('Position',subplot_position(2,1,1));
plot(doy,[N_org_MainEddy N_MainEddy]);
%subplot_label(gca,3,1,1,doy_ticks,3.4e4:0.2e4:3.8e4,2)
ylabel('N')

% Sampling delays
subplot('Position',subplot_position(2,1,2));
plot(doy,[del_CO2_MainEddy del_H2O_MainEddy],'o');
legend('CO2','H2O')
%subplot_label(gca,3,1,3,doy_ticks,-5:5:25,2)
ylabel('CP delay (samples)')

zoom_together(gcf,'x','on')


return

function y_ticks = yticks(x,dec)

if ~exist('dec') | isempty(dec)
   dec = 1
end

y_ticks = [floor(min(x)./dec).*dec:dec:ceil(max(x)./dec).*dec];
%y_ticks = [min(y_ticks) max(y_ticks)];

if isnan(sum(y_ticks))
   y_ticks = [0 dec];
end

return

