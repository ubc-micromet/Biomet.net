function r = mixingRatioMet(P,T,RH)
% Calculate water vapour mixing ratio from met data
% Rosie Howard
% 2 May 2024
%
% Reference 
% Stull, 2017: Practical Meteorology, pp.89-92
%
% Inputs:   P = air pressure (kPa)
%           T = temperature (degC)
%           RH = relative humidity (%)
%
% Output:   r = water vapour mixing ratio (g kg^-1)

% constants
Rv = 461;       % water vapour gas constant (J kg^-1 K^-1)
eps = 622;    % Rd/Rv (g_vapour/kg_dryair)
T0 = 273.15;    % reference temperature (K)
e0 = 0.6113;    % reference vapour pressure (kPa)
Lv = 2.5e6;     % latent heat of vaporization (J kg^-1)
% Ld = 2.83e6;    % latent heat of deposition (J kg^-1) 

T_K = T + 273.15;   % convert temperature to Kelvin

% calculate vapour pressure (kPa)
e_sat = e0*exp((Lv/Rv) * ( (1/T0) - (T_K.^(-1)) ));        % Clausius-Clapeyron eqn.
e = e_sat.*RH/100;

% calculate mixing ratio, r
r = (eps*e)./(P - e);

% EOF

