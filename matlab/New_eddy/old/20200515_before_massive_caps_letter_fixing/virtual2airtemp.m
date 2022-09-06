function [Tair] = virtual2airtemp(Tv,chi);

% Inputs: Tv = virtual air temperature in Kelvins or Deg C
%         chi= water vapour mmol h2o/mol moist air --> this is the same as
%              specific humidity (q), mg h2o/g moist air
% Outputs: Tair = air temperature in Kelvins or Deg C

% E. Humphreys  Oct 1, 2001

% Ref: Stull, R.B., 1995.  Meteorology Today for Scientists and Engineers, 
%         West Publ. Co.

Tair = Tv./(1 + 0.61.* chi./1000);