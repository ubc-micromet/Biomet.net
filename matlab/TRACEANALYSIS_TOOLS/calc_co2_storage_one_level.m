function co2_storage_one_level = calc_co2_storage_one_level(clean_tv,co2_mg,height)
% co2_storage_one_level = calc_co2_storage(clean_tv,co2_avg,height)
%
% This function calculates the CO2 storage from the groud to the 
% measurement level from the eddy co2 mixing ratio
%
%	Input:	   clean_tv    - matlab time vector
%              co2_mg      - co2 conc. in mg m^-3
%				   height	   - of measurement im m
%	Output:	   co2_storage - from a single point, in \mu mol m^-2 s^-1


% Revision:	Jun 15, 2001 kai*  Thanks to David who discovered that this
%                               function did storage differently than the 
%                               storage procedure now the procedures are
%                               unified.
%           Nov 24, 2000 kai*
%					converted this into a function using SOBS_CO2storage.m


% --- calculate storage term (dc/dt) ---

co2_storage = (co2_mg(3:end)-co2_mg(1:end-2))*(height/3600)*(1000/44);
co2_storage_one_level = [NaN;co2_storage;NaN];

% co2_mg is expressed as mg/m3
% co2 storage_tmp is integrated over an hour (3600 sec.)
% the factor (1000/44) comes from the transformation of mg/m-2s-1 to umolm-2s-1
% so (1g/1000mg)*(1mole/44g)*(10e6umol/mole) is equivalent to (1000/44)

% Bill had this exclusion critirion, which I am not going to use, since all the incoming data
% is supposed to be cleaned.
% ind 			= find(dcdt99bs > 10 | dcdt99bs < -5);
% dcdt99bs(ind)	= NaN*ones(length(ind),1);

