function [Ta,rho_a] = Ts2Ta_using_density(Ts,P,rho_v)
% FR_Ts2T Convert sonic temperature to air temperature
%
%   Ta = Ts2Ta_using_density(Ts,P,rho_v) does the 
%   conversion to Ta in degC using sonic temperature 
%   Ts in degC, barometric pressure P in kPa and molar 
%   density of water vapour rho_v in mmol/m^3. The 
%   inputs can be either scalars or vectors of the 
%   same length
%
%   [Ta,rho_a] = Ts2Ta_using_density(Ts,P,rho_v) also 
%   returns the density of dry air in mol/m^3.
%
%   For details of the theorie of the conversion see
%   'Calculating fluxes using sonic temperature' by kai*

% (c) kai* Nov 11, 2003

UBC_Biomet_constants

% Convert to inputs to base SI units (Pa,K,mol/m^3)
Ts    = Ts+ZeroK;
P     = P .* 1000;
rho_v = rho_v ./ 1000;

% Calculation of total density from sonic temperature
rho_s = P ./ (R .* Ts); 
chi_vs = rho_v./rho_s;
rho   = rho_s .* (0.5 + sqrt( 0.32 .* chi_vs + 0.25 ));
      
% Calculation of air temperature from total density
Ta     = P ./ (R .* rho) - 273.15;
      
if nargout == 2
   rho_a  = rho - rho_v;
end

return