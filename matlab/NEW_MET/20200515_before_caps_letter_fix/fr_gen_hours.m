function h = fr_gen_hours(Bat_voltage)
%
%   Calculate hours of generator operation by using the supplied
%   battery voltage. It is assumed that the time units are hhours.
%
%   Inputs:
%       Bat_voltage -   one of the chargers connected to AC power(GenHut)
%
%
% (c) Nesic Zoran           File created:       Apr  7, 1998
%                           Last modification:  Apr  7, 1998
%

% Revisions:
%       
VoltageTreshold = 13;

ind = Bat_voltage >= VoltageTreshold;
h = sum(ind)/ 2;
