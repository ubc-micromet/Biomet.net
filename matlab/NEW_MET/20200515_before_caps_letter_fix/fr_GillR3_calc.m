function [sonicOut,Tair_v,sos] = fr_GillR3_calc(sonic_poly, sonicIn,chi)
%
% Conversion of voltages to U,V,W and T for Gill R3 sonic. 
%
% inputs:
%       sonic_poly      - sonic polynomials, 2 rows ( [gain offset])
%       sonicIn         - input voltages (4 rows)
%       chi             - mol fraction (mol of water wapor/mol of air)
%
% outputs
%       sonicOut        - [u;v;w;T] (4 rows)
%       Tair_v          - virtual temperature
%       sos             - speed of sound
%
% (c) Zoran Nesic               File created:       Mar 24, 1999
%                               Last modification:  May 06, 2003

% Revisions:
% May  6, 2003 - Corrected humidity correction of air temperature to use mol fraction

   Tair_v   = polyval(sonic_poly(2,:),sonicIn(4,:));             % virtual temperature
   u        = polyval(sonic_poly(1,:),sonicIn(1,:));             % wind_u
   v        = polyval(sonic_poly(1,:),sonicIn(2,:));             % wind_v
   w        = polyval(sonic_poly(1,:),sonicIn(3,:));             % wind_w
   sos      = sqrt(abs((Tair_v + 273.15)*403));                  % speed of sound
   Tair_a   = (Tair_v + 273.15) ./ (1 + 0.32 .* chi ./ 1000);               % air temperature (humidity corrected)

   sonicOut = [u;v;w;(Tair_a-273.15)];                                    % prepare outputs


