function [relative_humidity_main, flag] = calc_relative_humidity_main(DOY, air_temperature_main,...
                                              barometric_pressure, h2o_mixing_ratio_main )
% Second level data processing function
%
% [relative_humidity_main, flag] = calc_relative_humidity_main(DOY, air_temperature_main,...
%                                             barometric_pressure, h2o_mixing_ratio_main )
%
% Calc relative humidity and clamp to 100%
%
% flag: just if NaN
%
% (C) Kai Morgenstern				File created:  31.08.00
%											Last modified: 31.08.00

% Revision: none

relative_humidity_main = 100 .* 489.7 .* (air_temperature_main+273.15) .* 0.622...
	 		.* rho_air(air_temperature_main) .* (barometric_pressure./100)...
			.* h2o_mixing_ratio_main ./ 1000 ./ (1000.*sat_vp(air_temperature_main));
ind_max = find(relative_humidity_main > 100);
relative_humidity_main(ind_max) = 100 .* ones(length(ind_max),1);
flag = isnan(relative_humidity_main);
