function [x,chi, Pcorr,Tcorr] = licor_h(hp, Th, Pb, Pg, Tcell, CalOffset, CalGain, v, units,PowX,Tair)
%
%   [x,chi, Pcorr,Tcorr] = licor_h(hp, Th, Pb, Pg, Tcell, CalOffset, CalGain, v, units,PowX,Tair)
%   
%
%   This function performs a full conversion of voltages into h2o. The units can
%   be selected between mmol/mol and g/m^3
%
%   Input parameters:
%
%       hp          -   Licor h2o polynomial  (see licor.m)
%       Th          -   Licor temperature at the calibration time (see licor.m)
%       Pb          -   Barometric pressure
%       Pg          -   Sample cell pressure
%       Tcell       -   Optical bench temperature
%       CalOffset   -   Calibration offset [mV]
%       CalGain     -   Calibration gain/span [1]
%       v           -   Voltage values
%       units       -   Desired units: 'g' for g/m^3 or 'm' (default) for 'mmol/mol' 
%       PowX        -   pressure correction power coeff 0.9 (default) or 1
%       Tair        -   air temperature in degC
%
%   Output parameters:
%
%       x           -   water vapor concentration mmol/mol of dry air
%       chi         -   water vapor concentration mmol/mol of wet air
%       Pcorr       -   pressure correction coeff.
%       Tcorr       -   temperature correction coeff.
%
%  The polinomial and the temperature Th can be obtained by using licor.m function.
%    Example:  [cp,hp,Tc,Th] = licor(174)
%
%   (c) Zoran Nesic                     File created:           May 16, 1996
%                                       Last modification:      Jul 10, 1997


%
% Revisions:
%
%       Jul 10, 1997
%           Fixed the bug that caused this function to return a scalar instead of a
%           vector. Changed:
%               chi = polyval(hp,v) * Tcorr;
%               x = chi / (1 - chi/1000);                   
%               x = x * cc;
%           to:
%               chi = polyval(hp,v) .* Tcorr;
%               x = chi ./ (1 - chi/1000);                   
%               x = x .* cc;
%
%       May 13, 1997
%           Output has changed from:
%               [x,Pcorr,Tcorr] = licor_h(hp, Th, Pb, Pg, Tcell, CalOffset, CalGain, v, units,PowX,Tair)
%           to
%               [x,chi, Pcorr,Tcorr] = licor_h(hp, Th, Pb, Pg, Tcell, CalOffset, CalGain, v, units,PowX,Tair)
%           so the chi value (mmol/mol of wet air can be passed to licor_c to be used for
%           the corrections.
%
%       May 6, 1997         changed pressure correction from
%                           Po/(Pb-Pg) to [Po/(Pb-Pg)].^0.9 (see new LI-COR manual)
%
%                           Conversion to g/m^3 is changed so it can include
%                           the actual air temperature (before this change
%                           20degC has been assumed)
%                           
%

if ~exist('units')                                  % if argument units doesn't exist
    units = 'm';                                    % use default units (mmol/mol)
end

if ~exist('Tair')                                   % if Tair doesn't exist
    Tair = 20 + 273.16;                             % use Tair = 293degK
else
    Tair = Tair + 273.16;                           % else convert temp. to degK
end

if ~exist('PowX')                                   % if PowX doesn't exist
    PowX = 0.9;                                     % use PowX = 0.9    
end


Pcorr = ( 101.3 ./ (Pb - Pg) ).^ PowX;              % Pressure correction factor
Tcorr = (Tcell + 273.15) ./ (Th + 273.15);          % Temperature correction factor

v = ( v + CalOffset ) .* CalGain .* Pcorr;

chi = polyval(hp,v) .* Tcorr;                       % mmol/mol of wet air
x = chi ./ (1 - chi/1000);                          % mmol/mol of dry air

if units == 'g'
    cc = 1000/461*Pb./Tair;    
    x = x .* cc;
end