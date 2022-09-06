function xsite_site_report(tv_exp,SiteId,report_function_name)

arg_default('tv_exp',datenum(2005,4,21):datenum(floor(now)));
arg_default('SiteId','CR');
%arg_default('report_var',report_function_name);
arg_default('report_function_name','report_Std_avgDtr');

fr_set_site('XSITE','l')
Stats_xsite = fcrn_load_data(tv_exp);

h_diag = fcrn_plot_diagnostics(Stats_xsite);

h_bx = msgbox('Click to continue report','Continue');
waitfor(h_bx)


fr_set_site(SiteId,'l')
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site);
[dd,hh,db] = fr_get_local_path;
Stats_all(1).Configuration.pth_tv_exclude = hh;

% Winddir to exclude
wd = get_stats_field(Stats_all,'Instrument(14).Avg(2)');
tv = get_stats_field(Stats_all,'TimeVector');
tv_exclude = tv(find(wd < 250));
fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},report_function_name,tv_exclude,1,[20 20.8333]);
fcrn_print_report(h_rep,'e:\',textResults);

