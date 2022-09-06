function xsite_ab_wpl_pi_comp

[data_xls,header_xls] = xlsread('D:\Experiments\AB-WPL\SiteData\hhour\WP-Flx-June16-18 2004.xls');

dt_xls = datenum(2004,6,16,16,45,0) - data_xls(1,1);
tv_pi = data_xls(:,1) + dt_xls + datenum(0,0,0,0,15,0);

H_pi = data_xls(:,find(strcmp('H',header_xls(1,:))));
LE_pi = data_xls(:,find(strcmp('LE',header_xls(1,:))));
Fc_pi = data_xls(:,find(strcmp('Fc',header_xls(1,:))));
Ust_pi = data_xls(:,find(strcmp('U*',header_xls(1,:))));

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

system_names = {'XSITE_CP','MainEddy'};
config_plot = 'report_var';

tv_exclude = fcrn_load_tv_exclude(Stats_all,system_names,config_plot);
h = fcrn_plot_comp(Stats_all,system_names,config_plot,tv_exclude,[],1)
return

