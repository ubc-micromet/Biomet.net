function Stats_all = xsite_on_gr_SonicPointingSouth

tv_exp = datenum(2005,8,2):now;

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'on_gr','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'on_gr','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site);
Stats_all(1).Configuration.pth_tv_exclude = Stats_all(1).Configuration.hhour_path;
tv = get_stats_field(Stats_all,'TimeVector');

[dum,dum,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','clean_tv'),8);;
wd = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','wind_direction_main'));;
precip = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','precipitation'));;

[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));

AGC_xsite = get_stats_field(Stats_all,'Instrument(3).MiscVariables.AGC_Max');
wd_xsite  = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
wd_hist   = get_stats_field(Stats_all,'MiscVariables.WindDirHistogram');

% Directional cov
co2_min_xsite  = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Min(5)');
co2_min_main   = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Min(5)');
n = get_stats_field(Stats_all,'XSITE_CP.CovWithDir.n');
cov_wT_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Cov(3,4)');
cov_wT_sonic = get_stats_field(Stats_all,'Instrument(1).Cov(3,4)');
cov_wT_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Cov(3,4)');

sum12= get_stats_field(Stats_all,'XSITE_CP.CovWithDir.sum12');
sum1 = get_stats_field(Stats_all,'XSITE_CP.CovWithDir.sum1');
sum2 = get_stats_field(Stats_all,'XSITE_CP.CovWithDir.sum2');
n    = get_stats_field(Stats_all,'XSITE_CP.CovWithDir.n');
sum12_main= get_stats_field(Stats_all,'MainEddy.CovWithDir.sum12');
sum1_main = get_stats_field(Stats_all,'MainEddy.CovWithDir.sum1');
sum2_main = get_stats_field(Stats_all,'MainEddy.CovWithDir.sum2');
n_main    = get_stats_field(Stats_all,'MainEddy.CovWithDir.n');

cov_wT_dir = [nansum(sum12')./nansum(n') - nansum(sum1').*nansum(sum2')./nansum(n').^2]';
cov_wT_sec = sum12./n - sum1 .* sum2 ./ n.^2;
cov_wT_sec_main = sum12_main./n_main - sum1_main .* sum2_main ./ n_main.^2;

for i = 1:36
    ind = find(tv>datenum(2005,8,10,1,0,0) ...
        & n_main(:,i)>1e3 & n(:,i)>1e3 ...
        & co2_min_main > 10 & co2_min_xsite > 10);
    if length(ind)>15
        a(i,:) = linregression_orthogonal(cov_wT_sec(ind,i),cov_wT_sec_main(ind,i));
        figure('Name',num2str(i));
        plot_regression(cov_wT_sec(ind,i),cov_wT_sec_main(ind,i),[],[],'ortho');
    end
end

ind_dir = 25:29;
cov_wT_sec1 = [nansum(sum12(:,ind_dir)')./nansum(n(:,ind_dir)') - nansum(sum1(:,ind_dir)').*nansum(sum2(:,ind_dir)')./nansum(n(:,ind_dir)').^2]';
n_include = nansum(n(:,ind_dir)')';
ind_include = find(tv>datenum(2005,8,10,1,0,0) ...
    & co2_min_main > 10 & co2_min_xsite > 10 & n_include>1e10);

plot_regression(cov_wT_sec1(ind_include),cov_wT_main(ind_include))

ind_include = find(tv>datenum(2005,8,10,1,0,0) ...
    & co2_min_main > 10 & co2_min_xsite > 10 );



return
