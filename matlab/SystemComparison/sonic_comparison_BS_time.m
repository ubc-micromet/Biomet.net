tv_data = datenum(2004,5,[14 16:18 20:24 26]);
Stats_1 = xsite_load_comparison_data(tv_data,'bs_new_eddy');
tv = get_stats_field(Stats_1,'TimeVector');
Hs_xs = get_stats_field(Stats_1,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_bs = get_stats_field(Stats_1,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
ind_bs = find(Hs_bs>600); 
Hs_bs(ind_bs) = NaN;

plot([Hs_xs,Hs_bs])

for i = 1:length(tv_data)
    ind = find(floor(tv) == tv_data(i));
    a(i,:) = linregression(Hs_xs(ind),Hs_bs(ind));
    figure;
    plot_regression(Hs_xs(ind),Hs_bs(ind));
end

    