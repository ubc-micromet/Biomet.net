Stats_site = fcrn_load_data(datenum(2005,8,3:5));

no_spikes = get_stats_field(Stats_site,'MainEddy.CSAT_Spikes.Spikes');
w_spikes  = get_stats_field(Stats_site,'MainEddy.CSAT_Spikes.mean_w');
w         = get_stats_field(Stats_site,'MainEddy.Zero_Rotations.Avg(3)');
std_w     = get_stats_field(Stats_site,'MainEddy.Zero_Rotations.Std(3)');