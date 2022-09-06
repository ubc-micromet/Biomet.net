function soil_heat_flux_total = calc_soil_heat_flux_total(tv, ...
    soil_heat_flux_plates_avg,soil_moisture_1,soil_temperature_integrated_top,...
    z,thetaO,thetaM)
% Second level data processing function
%
% soil_heat_flux_total = calc_soil_heat_flux_total(tv, ...
%    soil_heat_flux_plates_avg,soil_moisture_1,soil_temperature_integrated_top,...
%    z,theta_O,theta_M)
%
% This program calculates the soil surface heat flux G0 from soil heat 
% flux plats and storage between 0 and the soil heat flux plates.
% The parameter site is used to retrive the following information:
%
% Site  depth z thetaO  thetaM  porosity
% BS    0.1     0.15    0       0.85
% CR    0.02    0       0.29    0.71     Elyn's heat storage values
% JP    0.1     0       0.55    0.85
% PA    0.03    0.15    0.15    0.45
%
% (theta*: volumetric content of organic matter, minerals and water)
% The storage in the soil down to the heat flux plates is then calculated as
%   M = z*(2.5 * thetaO + 2.0 * thetaM + 4.18 * thetaW)*delta_T/delta_t.

% kai*  created:        June 7, 2001
%       Last modified:  June 7, 2001
%
% Reference: P.D. Blanken (1997) Evaporation within and above
%					a boreal aspen forest. PhD thesis(3.2.4), University of
%					British Columbia, Vancouver, Canada.

% Revision: 
% Dec 5, 2001 - added option to output flux when storage is not avail; E.Humphreys
% Feb 18, 2002 - removed site option from function line - soil properties are now input
%           in the function line; E.Humphreys
%

if nargin < 5
    z      = 0.1;
    thetaO = 0.15; %assumes 85% porosity associated with organic horizons
    thetaM = 0;
end
%the following deals with historic program where 5th argument in was a site ID
if isstr(z);
    z = 0.1;
    thetaO = 0.15; %assumes 85% porosity associated with organic horizons
    thetaM = 0;
end

%1800 s/half hour
delta_t 	= 1800;

% Volumetric content of minerals, organic matter and water in top layer
thetaM_top = thetaM.*ones(length(tv),1);
thetaO_top = thetaO.*ones(length(tv),1);
thetaW_top = soil_moisture_1;
%check that thetaW is a fraction;
ind = find(~isnan(thetaW_top ));
if thetaW_top(ind(1)) > 1;
    thetaW_top = thetaW_top./100;
end

%half hour change in temperature above SHFP (soil heat flux plate)
delta_T 	= [NaN; diff(soil_temperature_integrated_top)];

%mean heat capacity for layer above SHFP (MJ m^-3 degC^-1)
C 			= 2.00*thetaM_top + 2.50*thetaO_top + 4.18*thetaW_top;

soil_heat_storage_to_SHFP = 1.0e6.*z.*C.*delta_T/delta_t; %(W m^-2)

flag_storage = isfinite(soil_heat_storage_to_SHFP);
flag_average = isfinite(soil_heat_flux_plates_avg);
flag = flag_storage + flag_average;

%replace soil heat flux total results with SHFP values when storage is NaN
ind = find(isnan(soil_heat_storage_to_SHFP));

soil_heat_flux_total	    = soil_heat_flux_plates_avg + soil_heat_storage_to_SHFP;
soil_heat_flux_total(ind)	= soil_heat_flux_plates_avg(ind);

flag(find(isfinite(soil_heat_flux_total) ~= 1)) = NaN;


