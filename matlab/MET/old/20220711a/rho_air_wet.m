function [density_of_moist_air] = rho_air_wet(T,RH,Pb,h2o);
%rho_air_wet.m Calculates the density of moist air (kg/m3)

% Inputs: T, deg C - air temperature
%        RH, % or enter [] if using h2o
%        Pb, kPa - barometric pressure
%        optional: h2o, mmol/mol wet air - water vapour mole fraction

% Outputs: kg/m3
% p 52 Wallace and Hobbs (1977) Atmospheric Science - An Introductory Survey
%

% Revisions:
% 
% Mar 6, 2002
%   - changed the units from g/m3 to kg/m3
%
% E.Humphreys  Oct 1, 2001


%read in constants
UBC_biomet_constants;

if nargin < 4;
    Pb = Pb.*1000; % Pa
    e  = RH.*(0.61365*exp((17.502*T)./(240.97+T)))./100;  %convert RH% to e (kPa) (DewPt generator manual)
    e  = e.*1000;  %Pa
    
    density_of_moist_air = ((Pb-e)./(Rd.*(T+ZeroK))) + e./(Rv.*(T+ZeroK))./1000;
else
    %Ref: Wallace and Hobbs(1977) ... convert q to e via q = 0.622e/Pbar
    Pb = Pb.*1000; % Pa
    density_of_moist_air      = Pb.*...
                               (Ma.*(1-h2o./1000)+Mw.*h2o./1000)./...
                               (T+ZeroK)./(R)./1000;
end

