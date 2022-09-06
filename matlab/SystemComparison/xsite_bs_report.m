tv_data = datenum(2004,5,14);

[Stats_all,Stats_new,Stats_xsite] = fcrn_load_comparison_data(tv_dat,'bs_new_eddy');

tv_exclude = fcrn_clean(Stats_all,[],{'XSITE_CP','MainEddy'},'report_var');

save e:\temp\tv_exclude tv_exclude;