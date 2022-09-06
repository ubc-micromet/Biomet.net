function [sonicOut,Tair_v,sos_corrected, sos] = fr_GillR2_calc(sonic_poly, sonicIn,chi, resample20Hz)
%
% Conversion of voltages to U,V,W and T for Gill R2 sonic. 
%
% inputs:
%       sonic_poly      - sonic polynomials, 2 rows ( [gain offset])
%       sonicIn         - input voltages (4 rows)
%       chi             - mol fraction (mol of water wapor/mol of air)
%       resample20Hz    - if this flag is not 0 then program will resample the R2 data from 20.833Hz to
%                         20Hz
% outputs
%       sonicOut        - [u;v;w;T] (4 rows)
%       Tair_v          - virtual temperature
%       sos             - speed of sound
%
% (c) Zoran Nesic               File created:       Apr 12, 2001 (used fr_GillR3_calc as starting point)
%                               Last modification:  May 06, 2003

% Revisions:
% May  6, 2003 - Corrected humidity correction of air temperature to use mol fraction

   u        = polyval(sonic_poly(1,:),sonicIn(1,:));            % wind_u
   v        = polyval(sonic_poly(1,:),sonicIn(2,:));            % wind_v
   w        = polyval(sonic_poly(1,:),sonicIn(3,:));            % wind_w
   sos      = polyval(sonic_poly(2,:),sonicIn(4,:));            % speed of sound before cross wind correction
   v_n2     = 0.5 * (u + w).^2 + v.^2;
   sos_corrected   = (sos.^2 + v_n2).^0.5;                      % cross wind correction
   Tair_v   = sos_corrected .^ 2 ./403 - 273.15;                % virtual air temp.
   
   Tair_a   = (Tair_v + 273.15) ./ (1 + 0.32 .* chi ./ 1000);               % air temperature (humidity corrected)

   sonicOut = [u;v;w;(Tair_a-273.15)];                                    % prepare outputs

   try
        if resample20Hz ~= 0
            sonicOut = resample(sonicOut',120,125)';            % resample data to 20Hz if needed
        end
   end           
