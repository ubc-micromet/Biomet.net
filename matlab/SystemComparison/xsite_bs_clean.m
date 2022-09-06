function xsite_bs_clean(print_flag)

arg_default('print_flag',0);

close all

tv_dat = datenum(2004,5,[14:30]);

[Stats_all,Stats_new,Stats_xsite] = fcrn_load_comparison_data(tv_dat,'C:\UBC_PC_Setup\Site_specific\bs_new_eddy');

% [tv_exclude] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_var');
% [tv_exclude] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'sonic_comp');

%--------------------------------------------------------------------------
% Load 'best estimate' climate data  
%--------------------------------------------------------------------------
tv  = get_stats_field(Stats_all,'TimeVector');
pth = biomet_path(2004,'bs','clean\secondstage');
tv_db         = fr_round_hhour(read_bor(fullfile(pth,'clean_tv'),8));
[junk,ind_tv,ind_db]=intersect(tv,tv_db);

T_air         = read_bor(fullfile(pth,'air_temperature_main'),[],[],[],ind_db);
p_bar         = read_bor(fullfile(pth,'barometric_pressure_main'),[],[],[],ind_db);
Rn            = read_bor(fullfile(pth,'radiation_net_main'),[],[],[],ind_db);
windDir = read_bor(fullfile(pth,'wind_direction_main'),[],[],[],ind_db);

% Other possible exclusion criteria
tv_exclude_rep = fcrn_load_tv_exclude(Stats_all,{'XSITE_CP','MainEddy'},'report_var');
tv_exclude_son = fcrn_load_tv_exclude(Stats_all,{'XSITE_CP','MainEddy'},'sonic_comp');
ind = find(windDir < 100);
tv_exclude_rep_dir = unique([tv_exclude_rep; tv(ind)]);
tv_exclude_son_dir = unique([tv_exclude_son; tv(ind)]);

%--------------------------------------------------------------------------
% Time periods of the experiment (see diagnostic plot below)
% Setup Date(GMT)   MainEddyBoom    XSITEBoom   u     u_var v_var w_var Hs   T_var
% 1     14-27(26)   or              xs          1.03  1.12  0.95  0.92  1.05 1.24
% 2     28          or              nw          0.995 1.08  0.98  0.90  0.99 1.10
% 3     29          nw              xs                1.04  0.99  0.88  0.87 0.90
%
% Periods defined below
% DOY 138-141 Setup 1 - Good days 
% DOY 146-147 Setup 1 - Last days before field trip (weather not good)
% DOY 149     Setup 2 - First sonic swap ()
% DOY 150     Setup 3 - Second sonic swap
%--------------------------------------------------------------------------
ind_org = find(tv>=datenum(2004,1,138) & tv<datenum(2004,1,142));
ind_bef = find(tv>=datenum(2004,1,145) & tv<datenum(2004,1,147));
ind_sw1 = find(tv>=datenum(2004,1,149) & tv<datenum(2004,1,150));
ind_sw2 = find(tv>=datenum(2004,1,150) & tv<datenum(2004,1,151));

%--------------------------------------------------------------------------
% Diagnostic plots for entire period 
h0 = fcrn_plot_diagnostics(Stats_xsite,T_air,p_bar,Rn,windDir);

%--------------------------------------------------------------------------
% Setup 1 - good days
h1a = fcrn_plot_comp(Stats_all(ind_org),{'XSITE_CP','MainEddy'},'report_var',tv_exclude_rep_dir,{'Setup1_good_days'});

%--------------------------------------------------------------------------
% Setup 1 - before field trip
h1b = fcrn_plot_comp(Stats_all(ind_bef),{'XSITE_CP','MainEddy'},'report_var',tv_exclude_rep_dir,{'Setup1_before_trip'});

%--------------------------------------------------------------------------
% For the days during the trin there were too few meaningfull points 
% So we just do the sonic comparison sonic comparison in the three setups 
h1s = fcrn_plot_comp(Stats_all(ind_bef),{'XSITE_CP','MainEddy'},'sonic_comp',...
    tv_exclude_rep_dir,{'Sonic_comp_Setup1'});
h2s = fcrn_plot_comp(Stats_all(ind_sw1),{'XSITE_CP','MainEddy'},'sonic_comp',...
    tv_exclude_son_dir,{'Sonic_comp_Setup2'});
h3s = fcrn_plot_comp(Stats_all(ind_sw2),{'XSITE_CP','MainEddy'},'sonic_comp',...
    tv_exclude_son_dir,{'Sonic_comp_Setup3'});

%--------------------------------------------------------------------------
% Comparison of Sonic vs. Tc heat fluxes 
h4 = xsite_bs_H_comp(Stats_all,tv_exclude_son_dir,ind_org,ind_bef,ind_sw1,ind_sw2);

%--------------------------------------------------------------------------
% Print
%--------------------------------------------------------------------------
if print_flag
    fcrn_print_report(h0,'e:\temp');
    fcrn_print_report(h1a,'e:\temp');
    fcrn_print_report(h1b,'e:\temp');
    fcrn_print_report(h1s,'e:\temp');
    fcrn_print_report(h2s,'e:\temp');
    fcrn_print_report(h3s,'e:\temp');
    fcrn_print_report(h4,'e:\temp');
end    

return

