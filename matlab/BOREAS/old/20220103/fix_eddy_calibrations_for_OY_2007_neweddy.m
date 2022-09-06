% Fix bad CO2 eddy calibration at OY

%  June 25, 2008:  NickG
%------------------------------------------------------
% Fix bad eddy cals for OY, 2007
%------------------------------------------------------
%
% Load the original file
%
calFileName = 'D:\HFREQ_OY\MET-DATA\calextr_20080624\hhour\calibrations.cO1.mat';
load(calFileName);

calTime  = get_stats_field(cal_values,'TimeVector');
CO2_zero = get_stats_field(cal_values,'corrected.Cal0.CO2');
CO2_span = get_stats_field(cal_values,'corrected.Cal1.CO2');

% find bad calibrations
doy = calTime -datenum(2007,1,0);
ind_bad = find((doy>=9 & doy<12) | (CO2_zero>0 & (doy>=108 & doy<112)));
% block bad cals
for i=1:length(ind_bad), cal_values(ind_bad(i)).Ignore = 1; end

% Save the eddy fix results
save(calFileName,'cal_values');
