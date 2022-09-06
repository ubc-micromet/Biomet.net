function h = xsite_ab_wpl_comp_u_comp

tv_exp = datenum(2004,6,16:21);
cd c:\ubc_pc_setup\site_specific
Stats_xsite = fcrn_load_data(tv_exp);

cd C:\UBC_PC_Setup\Site_specific\AB-WPL
% new_calc_and_save(datenum(2004,6,16:20),'AB_WPL',1);
Stats_ab_wpl = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_ab_wpl,7/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_ab_wpl(1).Configuration.hhour_path;

tv = get_stats_field(Stats_all,'TimeVector');
u_std_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Std');
u_std_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Std');

%fcrn_clean(Stats_all,{'MainEddy','XSITE_CP'},'sonic_cal');
% Incorporate cleaning results
tv_exclude = fcrn_load_tv_exclude(Stats_all,{'MainEddy','XSITE_CP'},'sonic_cal');
[tv_dum,ind_ex] = intersect(fr_round_hhour(tv),fr_round_hhour(tv_exclude));
u_std_pi(ind_ex,:) = NaN;
u_std_xs(ind_ex,:) = NaN;

figure
subplot(2,1,1);
plot([u_std_xs(:,1),u_std_pi(:,1)])
subplot(2,1,2);
plot([u_std_xs(:,2),u_std_pi(:,2)])

% => u and v are swapped?!

% Doing regressions assuming Larry's sonic is right

h.hand = figure;
h.name = ['sonic_calibration_ab_wpl'];

subplot(2,2,1)
plot_regression(u_std_pi(:,2),u_std_xs(:,1),[],[],'ortho')
xlabel('\sigma_u Site (m/s)'); ylabel('\sigma_u Site (m/s)');
subplot(2,2,2)
plot_regression(u_std_pi(:,1),u_std_xs(:,2),[],[],'ortho')
xlabel('\sigma_v Site (m/s)'); ylabel('\sigma_v Site (m/s)');
subplot(2,2,3)
plot_regression(u_std_pi(:,3),u_std_xs(:,3),[],[],'ortho')
xlabel('\sigma_w Site (m/s)'); ylabel('\sigma_w Site (m/s)');
subplot(2,2,4)
plot_regression(u_std_pi(:,4),u_std_xs(:,4),[],[],'ortho')
xlabel('\sigma_T Site (m/s)'); ylabel('\sigma_T Site (m/s)');

% Table of regression parameters
a_u = linregression_orthogonal(u_std_pi(:,2),u_std_xs(:,1));
a_v = linregression_orthogonal(u_std_pi(:,1),u_std_xs(:,2));
a_w = linregression_orthogonal(u_std_pi(:,3),u_std_xs(:,3));
a_T = linregression_orthogonal(u_std_pi(:,4),u_std_xs(:,4));

disp(sprintf('Reg. u: %3.2f +/- %3.2f',a_u(1),a_u(5)));
disp(sprintf('Reg. v: %3.2f +/- %3.2f',a_v(1),a_v(5)));
disp(sprintf('Reg. w: %3.2f +/- %3.2f',a_w(1),a_w(5)));
disp(sprintf('Reg. T: %3.2f +/- %3.2f',a_T(1),a_T(5)));

% Reg. u: 1.03 +/- 0.01
% Reg. v: 1.01 +/- 0.01
% Reg. w: 0.94 +/- 0.01
% Reg. T: 0.95 +/- 0.04

% Decision on correction factors:
% only w = w/0.94