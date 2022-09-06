function [CO2mean,CO2std,dunk] = calculateUnknownCO2(co2stats_unknown, co2stats_target, CalAES);
UNK = co2stats_unknown(:,1);
CAL3 = co2stats_target(:,1);

dcal3 = CAL3 - CalAES;

dunk = UNK-dcal3;
dunk_stats = [mean(dunk) std(dunk) min(dunk) max(dunk)];
CO2mean = dunk_stats(1);
CO2std  = dunk_stats(2);


