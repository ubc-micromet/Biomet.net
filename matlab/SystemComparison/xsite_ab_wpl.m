function xsite_ab_wpl

%---------------------------------------------------------------------
% Diagnostics
tv_exp = datenum(2004,6,16:21);
cd c:\ubc_pc_setup\site_specific
% new_calc_and_save(tv_exp,'XSITE',1);

Stats_xsite = fcrn_load_data(tv_exp);
Stats_xsite(1).Configuration.pth_tv_exclude = Stats_xsite(1).Configuration.hhour_path;
tv_xs = get_stats_field(Stats_xsite,'TimeVector');

%---------------------------------------------------------------------
% Read site met-data
[Data_xls,Header_xls] = xlsread('D:\Experiments\AB-WPL\SiteData\met\AB_WPL_met.xls');

tv_met   = datenum(Data_xls(:,2),ones(length(Data_xls),1),Data_xls(:,3),floor(Data_xls(:,4)./100),mod(Data_xls(:,4),100),0);
[tv_dum,ind_met,ind_xs] = intersect(fr_round_hhour(tv_met+7/24,2),fr_round_hhour(tv_xs));
ind_Tair = intersect(find(strcmp('PRT Temp',Header_xls(2,:))),find(strcmp('Average',Header_xls(1,:))));
ind_Pbar = intersect(find(strcmp('P (kPa)', Header_xls(2,:))),find(strcmp('Average',Header_xls(1,:))));
ind_Rn   = intersect(find(strcmp('Rtot Net',Header_xls(2,:))),find(strcmp('Average',Header_xls(1,:))));
ind_Wd   = intersect(find(strcmp('Wind Dir',Header_xls(2,:))),find(strcmp('Average',Header_xls(1,:))));

vec_ini = NaN .* ones(length(tv_xs),1);
Tair = vec_ini; Pbar = vec_ini; Rn = vec_ini; WindDirection = vec_ini;
Tair(ind_xs)          = Data_xls(ind_met,ind_Tair);
Pbar(ind_xs)          = Data_xls(ind_met,ind_Pbar);
Rn(ind_xs)            = Data_xls(ind_met,ind_Rn);
WindDirection(ind_xs) = Data_xls(ind_met,ind_Wd);

h_diag = fcrn_plot_diagnostics(Stats_xsite,Tair,Pbar,Rn,WindDirection);

% fcrn_print_report(h_diag,'e:\');
%---------------------------------------------------------------------
% OP - CP
tv_exp = datenum(2004,6,18:21);
cd c:\ubc_pc_setup\site_specific
% new_calc_and_save(tv_exp,'XSITE',1);

[tv_ex,h_cpop] = fcrn_clean(Stats_xsite);
fcrn_print_report(h,'e:\kai');

%---------------------------------------------------------------------
% Comparison 
tv_exp = datenum(2004,6,16:21);
cd c:\ubc_pc_setup\site_specific
Stats_xsite = fcrn_load_data(tv_exp);

cd C:\UBC_PC_Setup\Site_specific\AB-WPL
% new_calc_and_save(datenum(2004,6,16:20),'AB_WPL',1);
Stats_ab_wpl = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_ab_wpl,7/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_ab_wpl(1).Configuration.hhour_path;

[tv_exclude,h_rep] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_var');