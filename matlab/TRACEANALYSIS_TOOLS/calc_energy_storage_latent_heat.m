function [energy_storage_latent_heat,flag] = calc_energy_storage_latent_heat(tv,...
      relative_humidity,air_temperature,barometric_pressure,dheight)
% Second level data processing function
%
% energy_storage_latent_heat = calc_energy_storage_latent_heat(tv,...
%      relative_humidity,air_temperature,barometric_pressure,dheight)
%
% This program calculates the energy stored as latent heat using matrices that contain
% air temperature and relative humidity. dheight is assumed to contain the layer thickness
% for each column of data.
%
% flag: 1 if finite,NaN otherwise
%
% This piece of code is based on Bill Chen's HeatStorage_cal.m
%
% (C) Kai Morgenstern				File created:  June 5, 2001
%									Last modified:  June 5, 2001
%
% Reference: P.D. Blanken (1997) Evaporation within and above
%					a boreal aspen forest. PhD thesis(3.2.4), University of
%					British Columbia, Vancouver, Canada.

% Revision: none

no_of_profile_pts = length(dheight);
% all arguments of psy_cons and spe_heat have to have the same dimension
barometric_pressure_mat = [];
for i = 1:no_of_profile_pts
    barometric_pressure_mat = [barometric_pressure_mat barometric_pressure];
end

%**************************************************************
%  calculate the rate of latent heat storage
%**************************************************************

% Assemble profiles

%Elyn - Nov 9, 2001 --> replace missing de data with nearest available level...
[relative_humidity] = calc_fill_with_nearest(relative_humidity);
[air_temperature]   = calc_fill_with_nearest(air_temperature);

saturation_vapour_pressure = sat_vp(air_temperature);
e  = (relative_humidity./100).*saturation_vapour_pressure; %unit: kPa
% all arguments of psy_cons and spe_heat have to be the same
gamma = psy_cons(air_temperature,e,barometric_pressure_mat);      
rho_cp = rho_air(air_temperature).*barometric_pressure_mat/100 .*spe_heat(e,barometric_pressure_mat);

ind = 2:length(tv)-1;

% Change in vapour pressure (halfhour before - halfhour after)
de = e(ind+1,:)-e(ind-1,:);
NA = NaN*ones(1,length(dheight));
de = [NA;de;NA];


Je = dheight*[(de.*rho_cp./gamma./3600)]';

energy_storage_latent_heat = Je';
flag = ones(length(tv),1);
flag(find(isfinite(energy_storage_latent_heat)==0)) = NaN;