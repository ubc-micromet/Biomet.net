function xsite_on_tp

tv_exp = datenum(2005,7,21:now);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'ON_TP','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'ON_TP','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,4/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_all(1).Configuration.hhour_path;
tv = get_stats_field(Stats_all,'TimeVector');

% h_diag = fcrn_plot_diagnostics(tv_exp,'ON_TP');

% fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',[],0,[20 20]);

% std_Ta_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Std(4)');
% std_Ts_xsite = get_stats_field(Stats_all,'Instrument(1).Std(4)');
% std_Tc_xsite  = get_stats_field(Stats_all,'Instrument(6).Std([1 2])');
% std_Ts       = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Std(4)');
% std_h2o     = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Std(6)');
% 
% plot_regression(tv(ind),[std_Ts_xsite(ind),std_Tc_xsite(ind,1)]);
% 
% plot(tv(ind),[std_Ts_xsite(ind),std_Tc_xsite(ind,1)],tv_db(ind_db),precip(ind_db));zoom on
% legend('Ts','Tc','Precip')
% 
% plot(tv(ind),[std_Ts_xsite(ind),std_Tc_xsite(ind,1), std_Ta(ind)],tv(ind),std_h2o(ind));zoom on
% legend('Ts','Tc','Ta','h2o')


[dum,dum,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','clean_tv'),8);;
wd = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','wind_direction_main'));;
precip = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','precipitation'));;

[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));

del  = get_stats_field(Stats_all,'MainEddy.Delays.Implemented');

tv_exclude_man = tv(find(tv< datenum(2005,7,25,18,0,0)+4/24 | (wd(ind_db)+60 < 200)) | abs(del(1)-del(2))>5 );
[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',tv_exclude_man,0,[20 20]);

return

tv_exclude_man = tv(find(tv> datenum(2005,7,27,18,0,0)+4/24 | (wd(ind_db)+60 < 200)) | abs(del(1)-del(2))>5 );
[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',tv_exclude_man,0,[20 20]);
