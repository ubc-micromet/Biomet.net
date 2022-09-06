function xsite_ab_wpl_wavg

cd c:\ubc_pc_setup\site_specific
Stats_xsite = fcrn_load_data(datenum(2004,6,16:21));

cd C:\UBC_PC_Setup\Site_specific\AB-WPL
Stats_ab_wpl = fcrn_load_data(datenum(2004,6,16:21));

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_ab_wpl,7/24);

field = '.Three_Rotations.Angles.Theta';
th_xs = get_stats_field(Stats_all,['XSITE_CP' field]);
th_xs = mod(th_xs-180,360)-180;
th_pi = get_stats_field(Stats_all,['MainEddy' field])-360;
th_pi = mod(th_pi-180,360)-180;

field = '.Zero_Rotations.Avg(1:3)';
u_xs = get_stats_field(Stats_all,['XSITE_CP' field]);
u_pi = get_stats_field(Stats_all,['MainEddy' field])-360;

figure
subplot(2,1,1)
hist(th_xs,-10:1:10)
subplot(2,1,2)
hist(th_pi,-10:1:10)
