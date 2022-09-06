field_str = 'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L';
fc_new = get_stats_field(Stats_new,field_str);
fc_org = get_stats_field(Stats,field_str);
figure
plot_regression(fc_org,fc_new,-10,300)

field_str = 'XSITE_OP_Tc.Three_Rotations.Std(10)';
fc_new = get_stats_field(Stats,field_str);
field_str = 'XSITE_OP_Tc.Three_Rotations.Std(6)';
fc_org = get_stats_field(Stats,field_str);
figure
plot_regression(fc_org,fc_new,-10,300)

new_calc_and_save(datenum(2004,7,[17:19 21:25]),'xsite')
