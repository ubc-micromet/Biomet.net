% fix_eddy_cals_at_OY

calFileName = 'D:\Nick_Share\recalcs\OY\recalc_20100113\hhour\calibrations.cO9.mat';

load(calFileName);

% if ~isfield(cal_values(1),'Ignore')
%     cal_values(1).Ignore=0;
%     for k=2:length(cal_values)
%         cal_values(k).Ignore=0;
%    end
% end

% correct bad zero cals due to bad cal relay software actuation (Nick, Apr
% 29, 2009)

tv = get_stats_field(cal_values,'TimeVector');
GMToffset = 8/24;
doy = tv-datenum(2009,1,0)-GMToffset;

% bad calibrations/no gas flowed or improper extraction
co2_z=get_stats_field(cal_values,'measured.Cal0.CO2');
ind_bad = find( co2_z>25); % bad zeros or bad Plicor

% set Ignore flag
for i=1:length(ind_bad)
   cal_values(ind_bad(i)).Ignore = 1;
end

% incorrect gain caused by >40ppm zero drift by new instrument 
% ind_drift=find(doy>= 155 & doy <168);
CAL_1_cal_cor = get_stats_field(cal_values,'corrected.Cal1.Cal_ppm');
co2_cor = get_stats_field(cal_values,'corrected.Cal1.CO2');
co2_z_cor = get_stats_field(cal_values,'corrected.Cal0.CO2');
% % set gain as 0.99 during that period in the init_all file and
% calculate the zero as the difference between CAL_1_ppm (actual) and co2
% (measured cal1, adjusted for gain)
gain_cor = 0.99;
cal1_zero = co2_z_cor;
cal1_zero(ind_drift) = gain_cor*co2_cor(ind_drift) - CAL_1_cal_cor(ind_drift);
% 
for i=1:length(cal_values)
     cal_values(i).corrected.Cal0.CO2 = cal1_zero(i);
end

save(calFileName,'cal_values','-v6');