function co2_storage = calc_co2_storage(clean_tv,co2_avg,height)
% co2_storage = calc_co2_storage(clean_tv,co2_avg,height)
%
% This function calculates the CO2 storage from the groud to the 
% measurement level.
%
%	Input:	    clean_tv    - matlab time vector
%				co2_avg     - co2 conc. in mg m^-3
%				height	    - of measurement im m
%	Output:	    co2_storage - from a single point, in \mu mol m^-2 s^-1


% Revision:	June 15, 2001 kai*  Thanks to David who discovered that this
%                               function did storage differently than the 
%                               storage procedure now the procedures are
%                               unified.
%            24 Nov, 2000 kai*
%					converted this into a function using SOBS_CO2storage.m


% --- calculate storage term (dc/dt) ---
co2_storage = (co2_avg(3:end)-co2_avg(1:end-2))*(height/3600)*(1000/44);
co2_storage = [NaN;co2_storage;NaN];

% Bill had this exclusion critirion, which I am not going to use, since all the incoming data
% is supposed to be cleaned.
% ind 			= find(dcdt99bs > 10 | dcdt99bs < -5);
% dcdt99bs(ind)	= NaN*ones(length(ind),1);

