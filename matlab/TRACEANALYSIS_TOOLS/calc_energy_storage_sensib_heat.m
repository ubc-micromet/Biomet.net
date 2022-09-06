function [energy_storage_sensib_heat,flag] = calc_energy_storage_sensib_heat(tv,...
      relative_humidity,air_temperature,barometric_pressure,dheight)

% Second level data processing function
%
% [energy_storage_sensib_heat,flag] = calc_energy_storage_sensib_heat(tv,...
%      relative_humidity,air_temperature,barometric_pressure,dheight)
%
% This program calculates the energy stored as sensible heat using matrices that contain
% air temperature and relative humidity. dheight is assumed to contain the layer thickness
% for each column of data.
%
% flag: 0 if vapor profile was not available, 1 otherwise
%
% This piece of code is based on Bill Chen's HeatStorage_cal.m
%
% (C) Kai Morgenstern				File created:  June 5, 2001
%									Last modified: June 5, 2001
%
% Reference: P.D. Blanken (1997) Evaporation within and above
%					a boreal aspen forest. PhD thesis(3.2.4), University of
%					British Columbia, Vancouver, Canada.

% Revision: Sep 15 2004: Changed nan to zero in final line (crs)

no_of_profile_pts = length(dheight);


%Elyn - Nov 9, 2001 --> replace missing de data with nearest available level...
[relative_humidity] = calc_fill_with_nearest(relative_humidity);
[air_temperature]   = calc_fill_with_nearest(air_temperature);

saturation_vapour_pressure = sat_vp(air_temperature);
e  = (relative_humidity./100).*saturation_vapour_pressure; %unit: kPa

% all arguments of psy_cons and spe_heat have to have the same dimension
barometric_pressure_mat = [];
for i = 1:no_of_profile_pts
    barometric_pressure_mat = [barometric_pressure_mat barometric_pressure];
end

cp_humid_air = spe_heat(e,barometric_pressure_mat);
cp_dry_air = 1004.67;
% In case no water vapour data is available assume dry air - It's better than NaN
cp_air = cp_humid_air;
cp_air(find(isfinite(cp_air) == 0)) = cp_dry_air;

rho_cp = rho_air(air_temperature) .*barometric_pressure_mat./100 .*cp_air;

%**************************************************************
%  calculate the rate of sensible heat storage
%**************************************************************

ind = 2:length(tv)-1;

% Change in sensible heat (halfhour before - halfhour after)
dT 		= air_temperature(ind+1,:)-air_temperature(ind-1,:);
NA 		= NaN*ones(1,length(dheight));
dT 		= [NA;dT;NA];

flag = isfinite(cp_humid_air);
energy_storage_sensib_heat = [dheight*(dT.*rho_cp)'/3600]';
flag(find(isfinite(energy_storage_sensib_heat) ~= 1)) = 0;
