function[Cmix, Hmix, C, H] = fr_convert_open_path_irga(co2, h2o, Tair, P);

%  Converts high frequency open path irga co2 and h2o concentrations to mixing ratios
%  IN:
%  co2      - mmol/m3
%  h2o      - mmol/m3
%  Tair     - deg C
%  P        - kPa

%  OUT:
%  Cmix - co2 umol/mol dry air
%  Hmix - h2o mmol/mol dry air
%  C    - co2 umol/mol wet air
%  H    - h2o mmol/mol wet air
%
% E.Humphreys  Sept 18, 2001
% 
% Revisions:
%   Nov 14, 2003 Kai       
%       - clarification of unit conversion

%constants:
UBC_biomet_constants;

%---------------------------------------------------------------------------
%convert h2o
H     = h2o.*R.*(Tair+ZeroK)./(1000.*P);                   %mmol/mol wet air;
Hmix  = H./(1-H./1000);                                    %mmol/mol dry air;

%convert co2
C     = co2.*R.*(Tair+ZeroK)./(1000.*P);                   %mmol/mol wet air;
Cmix  = C./(1-H./1000);                                    %mmol/mol dry air;
Cmix  = Cmix .* 1000;                                      %umol/mol dry air;

