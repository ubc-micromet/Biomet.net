function dir_surf(Stats_xsite)

[dir_hist] = get_stats_field(Stats_xsite,'MiscVariables.WindDirHistogram');
[tv]       = get_stats_field(Stats_xsite,'TimeVector');

[n,m] = size(dir_hist);
dir_range = zeros(n,m);
N  = sum(dir_hist,2);
[dir_sort,ind_s] = sort(dir_hist,2);
dir_cum = 1 - cumsum(dir_sort,2)./(N*ones(1,m));
ind_p = dir_cum<0.9;
for i = 1:n
    dir_range(i,ind_s(i,(find(ind_p(i,:))))) = 1;
end

figure
h=surf(dir_hist');
view(2)
set(h,'edgecolor','none','facecol','interp')
caxis([0 10000])

figure
h=surf(dir_range');
view(2)
set(h,'edgecolor','none')

return
