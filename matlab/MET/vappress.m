function [e_H,ea_H] = vappress(T, RH)
%vappress.m Program to convert RH to vapour pressure (kPa)

%
% Inputs:  T - HMP thermistor temperature output (deg C)
%          RH - HMP relative humidity output (%)
%
% Outputs: e_H - vapour pressure from HMP (kPa)
%          ea_H - saturation vapour pressure using HMP thermistor (kPa)
%           
% E.Humphreys Feb5, 1997
%----------------------------------------------------------------------------

ea_H = 0.61365*exp((17.502*T)./(240.97+T));  %saturation vapour pressure

e_H = RH.*ea_H./100;                         %HMP vapour pressure

%assume vapour pressure (e) is the same inside the HMP shield as outside...
