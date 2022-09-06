function [barometric_pressure, flag] = calc_barometric_pressure(clean_tv,...
                               bp_datalogger,bp_high_freq_avg )
% Second level data processing function
%
% function [barometric_pressure, flag] = calc_barometric_pressure(DOY,...
%                               barometric_pressure_datalogger,barometric_pressure_high_freq_avg )
%
% Calc barometric pressure by replacing NaN in datalogger data with corrected high freq data
%
% flag: if datalogger had NaN
%
% (C) Kai Morgenstern				File created:  07.09.00
%									Last modified: June 5,2001

% Revision: none

ind = find(~isnan(bp_datalogger) & ~isnan(bp_high_freq_avg));
offset = mean(bp_datalogger(ind)-bp_high_freq_avg(ind));

if isnan(offset)
    offset = 0;
end

ind = find(isnan(bp_datalogger)==1);
barometric_pressure      = bp_datalogger;
barometric_pressure(ind) = bp_high_freq_avg(ind) + offset;

flag = isnan(bp_datalogger);
