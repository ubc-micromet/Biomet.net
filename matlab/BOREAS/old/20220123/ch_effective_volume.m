function [ev_midnight, ev_noon] = ch_effective_volume(t,x,SiteID);
% Program that calculates the effective volume for each automated chamber
%
% used with tmp_pl_ch
%
% Created by David Gaumont-Guay Nov 19. 2001
% Revisions: none

t_tmp = datevec(t);
hour = t_tmp(:,4);
min  = t_tmp(:,5);

currentDate = t(end);

c = fr_get_init(SiteID,currentDate);

F    = c.chamber.flow_rate / 60;             % flow rate (ml\s)
Ccal = c.chamber.effective_vol_gas * 1e6;    % calibration tank concentration (ppm)

for i = 1:10:60;
   ind_chr_noon = find(hour == 12 & min == i+1);
   ind_cal_noon = find(hour == 12 & min == i+6);
   [dcdt_chr_noon, R2_chr_noon, sigma_chr_noon, s_chr_noon, Y_hat_chr_noon] = polyfit1([0:5:(length(ind_chr_noon)*5)-1]',x(ind_chr_noon),1);
   [dcdt_cal_noon, R2_cal_noon, sigma_cal_noon, s_cal_noon, Y_hat_cal_noon] = polyfit1([0:5:(length(ind_cal_noon)*5)-1]',x(ind_cal_noon),1);
   ev_noon(i) = ((F * Ccal) / (dcdt_cal_noon(1) - dcdt_chr_noon(1))) / 1000; % litres
   ind_chr_midnight = find(hour == 0 & min == i+1);
   ind_cal_midnight = find(hour == 0 & min == i+6);
   [dcdt_chr_midnight, R2_chr_midnight, sigma_chr_midnight, s_chr_midnight, Y_hat_chr_midnight] = polyfit1([0:5:(length(ind_chr_midnight)*5)-1]',x(ind_chr_midnight),1);
   [dcdt_cal_midnight, R2_cal_midnight, sigma_cal_midnight, s_cal_midnight, Y_hat_cal_midnight] = polyfit1([0:5:(length(ind_cal_midnight)*5)-1]',x(ind_cal_midnight),1);
   ev_midnight(i) = ((F * Ccal) / (dcdt_cal_midnight(1) - dcdt_chr_midnight(1))) / 1000; % litres
end
  
