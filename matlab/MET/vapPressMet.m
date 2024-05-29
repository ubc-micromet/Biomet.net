function [e,e_sat] = vapPressMet(T,RH)
% Calculate vapour pressure from met data
% Rosie Howard
% 2 May 2024
%
% Reference 
% Stull, 2017: Practical Meteorology, pp.89-92
%
% Inputs:   T = temperature (degC)
%           RH = relative humidity (%)
%
% Output:   e = vapour pressure in kPa
%           esat = saturated vapour pressure in kPa

% constants
Rv = 461;       % water vapour gas constant (J kg^-1 K^-1)
T0 = 273.15;    % reference temperature (K)
e0 = 0.6113;    % reference vapour pressure (kPa)
Lv = 2.5e6;     % latent heat of vaporization (J kg^-1)
% Ld = 2.83e6;    % latent heat of deposition (J kg^-1) 

T_K = T + 273.15;   % convert temperature to Kelvin

% calculate vapour pressure (kPa)
e_sat = e0*exp((Lv/Rv) * ( (1/T0) - (T_K.^(-1)) ));        % Clausius-Clapeyron eqn.
e = e_sat.*RH/100;

% EOF