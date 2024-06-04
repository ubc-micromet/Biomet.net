function Td = dewpointMet(T,RH)
% Calculate dewpoint temperature (degC) from met data
% Rosie Howard
% 1 May 2024
%
% Reference 
% Stull, 2017: Practical Meteorology, pp.89-92
%
% Inputs:   T = temperature in degC
%           RH = relative humidity in %
%
% Output:   Td = dewpoint temperature in degC

% constants
Rv = 461;       % water vapour gas constant (J kg^-1 K^-1)
T0 = 273.15;    % reference temperature (K)
e0 = 0.6113;    % reference vapour pressure (kPa)
Lv = 2.5e6;     % latent heat of vaporization (J kg^-1)
% Ld = 2.83e6;    % latent heat of deposition (J kg^-1) 

T_K = T + 273.15;   % convert temperature to Kelvin

% calculate saturation vapour pressure and vapour pressure
e_sat = e0*exp((Lv/Rv) * ( (1/T0) - (T_K.^(-1)) ));        % Clausius-Clapeyron eqn.
e = e_sat.*RH/100;

% dewpoint temperature
Td_K = (1/T0 - (Rv/Lv)*log(e/e0)).^(-1);
Td = Td_K - 273.15;     % convert to degC


% from LI-610 dew point generator's manual, for comparison:
% e_sat = 0.61365*exp((17.502*T)./(240.97+T));
% e = e_sat.*RH;
% z = log(e/0.61365);
% Tdew = 240.97*z./(17.502-z); 

% EOF