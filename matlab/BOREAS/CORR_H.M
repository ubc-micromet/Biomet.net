function SOUNDV = corr_H(Pbarometric, Tv, Temp, uw, wTv, w_sT_s, w_sq)
%
%   Pbarometric (Pa)
%   Tv                  - virtual temperature from Gill (degK)
%   Temp                - "real" temp (degC)
%   uw                  - cov(u,w)
%   wTv                 - cov(w,Tv)
%   w_sT_s              - cov(w_s,T_s)
%   w_sq                - cov(w_s, q)
%
%   Sensible heat corrections
%
%
%
% (c) Matthias Roth & Zoran Nesic       File created:       Nov  7, 1996
%                                       Last modification:  Feb 25, 1997

absTv = Tv + 273.16;
ATemp = Temp + 273.16;

% Pbarometric (Pa), Tv - Solent virtual temp. (degC)
RoAir = Pbarometric* 0.34838/(absTv*100);
%
% constants
%
EPSconst = 0.62197;                             % mol fraction
CA = 0.9995;                                    % expansion of air
RH = 51.2;                                      % rel. humidity
% saturation vapour pressure ES (Lowe 1977)
ESp = [6.136820929e-11 2.034080948e-8 3.031240396e-6 2.650648471e-4 1.428945805e-2 4.436518521e-1 6.10779961];
ES = polyval(ESp, Temp) * 100;                  %(Pa)
VAPP = ES*RH/100;                               % vapoure pressure (Pa)
MIXR = EPSconst * VAPP / (Pbarometric - VAPP);  % mixing ratio
CP = (0.2403 + (0.4409*MIXR)) * 4186.7456      % specific heat of air J/kg/K
LV = 1.91846e3 * ( ATemp/(ATemp - 33.91) )^2;   % LE of vaporisation J/g
ROV = 216.5 * VAPP * 0.01 / ATemp;              % vapour density (g/m^3)
ROSPEC = 0.622*VAPP/(Pbarometric - 0.378*VAPP); % specific humidity
SOUNDV = sqrt(ATemp *403*(1 + 0.51*ROSPEC));    % speed of sound

%
% Flux calculation
%
Ustar = sqrt(abs(uw));
QHv   = RoAir * CP * wTv;
QH_s  = RoAir * CP * w_sT_s;
QE    = LV * w_sq;

%
% Correction constants
%
KW1011 = 0.166;                 % calib. coeff for Krypton
KO     = 0.0045;                % O2 correction coeff for Krypton (changed: Feb 25, 1997)
% KO     = 0.0085;                % O2 correction coeff for Krypton (old, see above)
R      = 8.314;                 % univ. gas const.
MA     = 29;                    % mol. weight of air
MW     = 18;                    % mol. weight of H2O
MO     = 32;                    % mol. weight of O2
CO     = 0.21;                  % concentration of O2 in air

%
% O2 correction for Krypton acording to Taner and Green (1985?)
%
B = (CO*MO*1000)/(CP*MA);        %
C1011 = LV * B * KO / KW1011 * QH_s / ATemp  % additive correction to Krypton (W/m^2);

% Webb correction (W/m^2)
CD1011 = LV * ROV * QH_s / (CP * ATemp * RoAir) + LV * MA / MW * ROV / (RoAir*1000) * w_sq;

% adding corrections to the flux
CQE = QE + C1011 + CD1011;

%
% Sensible heat correction
%
% QH = QHv - A1 + A2
%
% QHv - sensible heat measured by Gill (virtual)
% QH  - actual sensible heat (the real one!)
% A1  - correction due to humidity
% A2  - correction due to crosswind  (WE DO NOT HAVE THIS, YET)
%
A1 = CP * 0.51 * ATemp * CQE / LV / 1000
A2 = 0 ;
QH = QHv - A1 + A2