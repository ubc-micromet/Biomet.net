function [x,Pcorr,Tcorr,DilCorr,BroCorr] = licor_c(cp, Tc, Pb, Pg, Tcell, CalOffset, CalGain, v, units, chi,flagX,Tair)
%
%  [x,Pcorr,Tcorr,DilCorr,BroCorr] = licor_c(cp, Tc, Pb, Pg, Tcell, CalOffset, CalGain, v, units, chi,flagX,Tair)
%
%   This function performs a full conversion of voltages into co2. The units can
%   be selected between ppm and mg/m^3
%
%   Input parameters:
%
%       cp          -   Licor co2 polynomial  (see licor.m)
%       Tc          -   Licor temperature at the calibration time (see licor.m)
%       Pb          -   Barometric pressure
%       Pg          -   Sample cell pressure
%       Tcell       -   Optical bench temperature
%       CalOffset   -   Calibration offset [mV]
%       CalGain     -   Calibration gain/span [1]
%       v           -   Voltage values [mV]
%       units       -   Desired units: 'g' for g/m^3 or 'm' for 'mmol/mol'
%       chi         -   water vapor mole fraction (mmol/mol of wet air)
%       flagX       -   [] or 0 for all corrections
%                       1 - without dilution correction
%                       2 - without broadening correction
%                       3 - without pressure correction
%                       4 - without temperature correction
%       Tair        -   air temperature in degC
%
%   Output parameters:
%
%       x           - co2 concentration (umol/mol or g/m^3 depending on the flagX)
%       Pcorr       - pressure correction factor
%       Tcorr       - temperature correction factor
%       DilCorr     - dilution correction factor
%       BroCorr     - broadening correction factor
%
%  The polinomial and the temperature Th can be obtained by using licor.m function.
%   example:  [cp,hp,Tc,Th] = licor(174)
%
%   (c) Zoran Nesic                     File created:           May 17, 1996
%                                       Last modification:      May 13, 1997
%

% Revisions:
%       May 13, 1997        Changes in the comment lines
%
%       May  6, 1997        Added dilution and pressure broadening corrections
%                           and the flagX to selectively remove corrections
%                           Conversion to g/m^3 is changed so it can include
%                           the actual air temperature (before this change
%                           20degC has been assumed)
%
%       Aug 18, 1996        Added units input parameter
%
%

if ~exist('units')                                  % if argument units doesn't exist
    units = 'm';                                    % use default units (umol/mol)
end
if ~exist('flagX')                                  % if argument flagX doesn't exist
    flagX = 0;                                      % set default flagX
end
if ~exist('chi')                                    % if input arg. chi doesn't exist
    chi = 0;                                        % set chi = 0
end
if ~exist('Tair')                                   % if Tair doesn't exist
    Tair = 20 + 273.16;                             % use Tair = 293degK
else
    Tair = Tair + 273.16;                           % else convert temp. to degK
end

Pcorr = 101.3 ./ (Pb - Pg);                         % pressure correction factor
Tcorr = (Tcell + 273.15) ./ (Tc + 273.15);          % temperature correction factor
DilCorr = 1000 ./ (1000 - chi);                     % dilution correction factor
a_chi = 1.57;                                       % water vapour broadening coeff.
BroCorr = 1 + (a_chi - 1) .* chi / 1000;            % broadening correction factor

v = ( v + CalOffset ) .* CalGain;                   % calibrate the voltage

if flagX ~= 3                                       % if the flagX says so
    v = v .* Pcorr;                                 % do the pressure correction
end

if flagX ~= 2                                       % if the flagX says so
    v = v ./ BroCorr;                               % do the first part of broadening corr.
end

x = polyval(cp,v);                                  % evaluate the polynomial

if flagX ~= 4                                       % if the flagX says so
    x = x .* Tcorr;                                 % do the temperature correction
end

if flagX ~= 1                                       % if the flagX says so
    x = x .* DilCorr;                               % do the dilution correction
end

if flagX ~= 2                                       % if the flagX says so
    x = x .* BroCorr;                               % do the second part of broadening corr.
end

if units == 'g'                                     % convert to the right units
    cc = 1000/189.*Pb./Tair;
    x = x .* cc;
end

%
% Calculation with all the corrections:
%
%   c = TempCorr * BroCorr * DillCorr * polyval( cp, v * Pcorr / BroCorr )
%
%