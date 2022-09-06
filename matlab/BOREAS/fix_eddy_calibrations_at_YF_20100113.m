
% local directory where cal files are located
fn_cal = 'D:\Nick_Share\recalcs\YF\recalc_20100112\hhour\calibrations.cY5.mat';

% read in calibration file

load(fn_cal);
  
%read cal data

tv = get_stats_field(cal_values,'TimeVector');

doy=tv-datenum(2009,1,0)-8/24;

co2_zero_m = get_stats_field(cal_values,'measured.Cal0.CO2');
co2_span_m = get_stats_field(cal_values,'measured.Cal1.CO2');
h2o_zero_m = get_stats_field(cal_values,'measured.Cal0.H2O');
h2o_span_m = get_stats_field(cal_values,'measured.Cal1.H2O');

co2_z_cor = get_stats_field(cal_values,'corrected.Cal0.CO2');
co2_span_cor = get_stats_field(cal_values,'corrected.Cal1.CO2');
h2o_z_cor = get_stats_field(cal_values,'corrected.Cal0.H2O');
h2o_span_cor = get_stats_field(cal_values,'corrected.Cal1.H2O');


%Find bad values

% bad calibrations/no gas flowed or improper extraction
co2_z=get_stats_field(cal_values,'measured.Cal0.CO2');
ind_bad = find( (doy>=1 & doy <366 & co2_z_cor > 100) |...
               (doy>282 & doy <288 & co2_z_cor>0)); % bad zeros 

% set Ignore flag for bad values
for i=1:length(ind_bad)
   cal_values(ind_bad(i)).Ignore = 1;
end

% incorrect gain caused by >20ppm zero drift 
ind_drift=find(doy>= 238 & doy <301);
CAL_1_cal_cor = get_stats_field(cal_values,'corrected.Cal1.Cal_ppm');
% % set gain as 0.99 during that period in the init_all file and
% calculate the zero as the difference between CAL_1_ppm (actual) and co2
% (measured cal1, adjusted for gain)
gain_cor = 0.995;
cal1_zero = co2_z_cor;
cal1_zero(ind_drift) = gain_cor*co2_span_cor(ind_drift) - CAL_1_cal_cor(ind_drift);
% 
for i=1:length(cal_values)
     cal_values(i).corrected.Cal0.CO2 = cal1_zero(i);
end


% save cal_values
save(fn_cal,'cal_values','-v6');
