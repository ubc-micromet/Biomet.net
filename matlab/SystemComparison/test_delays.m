Stats_all = fcrn_load_data(datenum(2004,3,4:21),'XSITE');

d_op = get_stats_field(Stats_all,'XSITE_OP.Delays.Calculated');

% Calculation of relative humidity
Fc    = get_stats_field(Stats_all,'XSITE_OP.Three_Rotations.AvgDtr.Fluxes.Fc');
h2o   = get_stats_field(Stats_all,'XSITE_OP.Three_Rotations.Avg(6)');
p_bar = get_stats_field(Stats_all,'Instrument(3).Avg(5)');
Ta    = get_stats_field(Stats_all,'MiscVariables.Tair');

e = p_bar .* (h2o./1000./(1+h2o./1000));
r_h = e./(sat_vp(Ta)) .*100;

figure
hist(d_op(:,1),-10:20)

ind = find( abs(Fc)>2 & (d_op(:,1)>-10 & d_op(:,1)<20) & r_h<120);
[r_avg,d_avg] = bin_avg(r_h(ind),d_op(ind,1),50);

figure
plot(r_h(ind),d_op(ind,1),'.',r_avg,d_avg,'r-o')
