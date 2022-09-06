function [H,Fc,LE] = WPL_LI7500(Ts,rho_c,rho_v,P,cov_hh,Conversion_Flag)
% WPL_LI7500 Fluxes using WPL terms on hhourly LI-7500 output
%
%   [H,Fc,LE] = WPL_LI7500(Ta,rho_c,rho_v,P,cov_hh) calculates
%   the half-hhourly fluxes of sensible heat (H), CO_2 (Fc) 
%   and latent heat (LE) from the half-hourly averages of 
%   air temperature (Ta in degC), molar density of CO_2 and 
%   water vapour (rho_c and rho_v both in mmol/m^-3) and the 
%   covariance matrix cov_hh = cov([u v w Ta rho_c rho_h])
%
%   [H,Fc,LE] = WPL_LI7500(Ts,rho_c,rho_v,P,cov_hhs,1) is the
%   same as above but uses sonic temperature Ts (in degC)
%   and the covariance matrix cov_hhs = cov([u v w Ts rho_c rho_h])
%   calculated from sonic temperature .
%
%   For details of the theorie of the sonic temperature and
%   heat flux conversion see
%   'Calculating fluxes using sonic temperature' by kai*

% (c) kai* Nov 11, 2003

UBC_Biomet_constants;

if ~exist('Conversion_Flag') | isempty(Conversion_Flag) 
    Conversion_Flag = 0;
end

% Convert to inputs to base SI units (Pa,K,mol/m^3)
Ts    = Ts+ZeroK;
P     = P .* 1000;
rho_v = rho_v ./ 1000;
rho_c = rho_c ./ 1000;
wp_Tsp    = cov_hh(3,4);
wp_rho_cp = cov_hh(3,5)./ 1000;
wp_rho_vp = cov_hh(3,6)./ 1000;

if Conversion_Flag == 1
    % Get air temperature
    [Ta] = Ts2Ta_using_density(Ts-ZeroK,P./1000,rho_v.*1000) + ZeroK;
    wp_Tp = wp_Tsp * (1 - 0.64*R*Ts*rho_v/P) - 0.32*R*Ts^2/P * wp_rho_vp;
else
    Ta = Ts;
    wp_Tp = wp_Tsp;
end

% Latent heat of vaporisation
L = lambda(Ta-ZeroK);

rho   = P./(R.*Ta); % density of moist mol/m3
rho_a = rho - rho_v;  % density of dry air mol/m3

% Sonic temperature covariance conversion
H  = (Cp.*rho_a.*Ma+Cpv.*rho_v.*Mw) .* wp_Tp;
%H  = 1004 .* rho_a .* Ma./1000 .* wp_Tp;

% WPL terms
% Convert to mass based - that's what WPL paper uses
rho_a_m     = rho_a * Ma./1000;

rho_v_m     = rho_v * Mw./1000;
wp_rho_vp_m = wp_rho_vp * Mw./1000;

rho_c_m     = rho_c * Mc./1000;
wp_rho_cp_m = wp_rho_cp * Mc./1000; 

sigma = rho_v_m / rho_a_m;
mu    = Ma./Mw;

LE = L * (1+mu*sigma)*(wp_rho_vp_m+rho_v_m/Ta*wp_Tp);
Fc = 1e6/0.04401 * (wp_rho_cp_m ...
   + mu*(rho_c_m/rho_a_m)*wp_rho_vp_m ...
   + (1+mu*sigma)*rho_c_m/Ta*wp_Tp);

return