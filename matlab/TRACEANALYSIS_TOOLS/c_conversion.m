function [C_out] = C_conversion(C_in, Tair, BarPress, flag)


%  This program converts CO2 concentration units or
%  w'c' covariances to CO2 fluxes.
%   i.e. 
%            for covariances
%  for flag     1 from  [ppm*(m/s)] (mole fraction of dry air) 
%                 to [(mg/m^3)*(m/s)] 
%               2 from  [(mg/m^3)*(m/s)] to [umol/(m^2 s)]
%               3 from  [ppm * (m/s)] to [umol/(m^2 s)]
%               4 from  [(mg/m^3) * (m/s)] to [ppm * (m/s)]
%               5 from  [umol/(m^2 s)] to [(mg/m^3) * (m/s)]
%               6 from  [umol/(m^2 s)] to [ppm * (m/s)]
%   or
%            for concentrations 
%               corresponding units without (m/s)
%   
%
%   inputs:     C_in         - CO2 concentration or covariance 
%               Tair         - air temperature at measurement height in [deg C}
%               BarPress     - barometric pressure in [kPa]
%               flag         - choice of conversion
%   
%
%   outputs: C_out  - CO2 concentration or flux 
%
%                       created on: March 18, 1998  by:  Eva Jork
%                       modified on:                by:
%
%
%

% constants used:       

Mc = 44;                % molecular weight of CO2 in [g mol^-1]
R = 8.314510;           % universal molar gas constant
%                       % in [J mol^-1 K^-1]
%
%   from:
%   p*V = n*R*T,            where        p = pressure of gas [Pa]
%                                        V = volume of gas   [m^3]
%                                        n = quantity        [mol]
%                                        T = temperature     [K]        
%
T = Tair + 273.15;              % air temperature in [K]
p = BarPress .* 1000;           % barometr. pressure in [Pa]


if flag == 1
   C_out = C_in .* Mc *10^(-3) ./ (R .* T./p);
end

if flag == 2
   C_out = C_in .* 1000/Mc;
end

if flag == 3
   C_out = (C_in .* Mc *10^(-3) ./ (R .* T./p)) .* 1000/Mc;
end

if flag == 4
   C_out = C_in .* (R .* T./p)./(Mc *10^(-3));
end

if flag == 5
   C_out = C_in .* Mc ./ 1000;
end

if flag ==6
   C_out = C_in .* ((R .* T./p)./(Mc *10^(-3)))...
      .* (Mc./1000);
end


