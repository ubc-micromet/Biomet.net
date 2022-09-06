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

% Revisions:
%
%  Apr 6, 2020 (Zoran)  NOTE: Ta interpolation. Read below!
%    - fixed a bug when a confused IRGA measuring negative moisture would
%    mess up the Tair, sensible heat and all other variables dependent on
%    Tair (high or low frequency)
%    - Added some QA/QC for Ta.  Ta has to stay between -50 and +50C. Bad
%      points are interpolated. If interpolation fails, the original Ta is
%      returned. This will affect all the calculations. Past results will 
%      show significant differences when compared. On the other hand, the bad Ta
%      caused meaningless results so not a big deal.
%  Jan 3, 2020 (Zoran)
%  - changed UBC_Biomet_constants to UBC_biomet_constants to keep Matlab >2012 compatibility
UBC_biomet_constants

% Convert to inputs to base SI units (Pa,K,mol/m^3)
Ts    = Ts+ZeroK;
P     = P .* 1000;
rho_v = abs(rho_v ./ 1000);         % Made rho_v positive so we don't end up with complex (x + i*y) numbers for Ta

% Calculation of total density from sonic temperature
rho_s = P ./ (R .* Ts); 
chi_vs = rho_v./rho_s;
rho   = rho_s .* (0.5 + sqrt( 0.32 .* chi_vs + 0.25 ));
      
% Calculation of air temperature from total density
Ta     = P ./ (R .* rho) - 273.15;

% do a basic QA/QC. Try to remove unreasonable air temperatures
% Ta > 50C or < -50C
indBadTa = Ta>50 | Ta < -50;
if any(indBadTa>0)
    fprintf('*** Unresonable Tair (most likely due to bad h2o measurements). Cleaning attempted. (in: Ts2Ta_using_density.m)\n')
    try
        Ta = interp1(1:length(find(indBadTa==0)),Ta(~indBadTa),1:length(Ta));
    catch
    end
end
      
if nargout == 2
   rho_a  = rho - rho_v;
end

return