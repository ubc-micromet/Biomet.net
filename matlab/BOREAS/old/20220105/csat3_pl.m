function [t, cup_3D_CSAT, cup_3D_Gill, Tair_CSAT, Tair_Gill] = csat3_pl(st, en)
%*************************************************************************
% This program compares half-hour data from the Campbell sonic anemometer (CSAT3) 
% with Gill R2 sonic.
%	
%		(c)  by Eva Jork			created on:		July 26, 1999
%							     	modified on: 	September 10, 1999
%
% INPUTS: DOY to start and end reading data
%
%
%*************************************************************************
GMT_to_PST = 8/24;
%*************************************************************************

% DEFINE PATHS
% TO READ IN DATA FROM FROM 's-files'
if exist('f:\CR\hhour\')
   pth = 'f:\CR\hhour\';
else
   pth = '\\Paoa_001\sites\CR\hhour\';
end
% TO READ IN DATA FROM CD-ROM
%pth_cd = 'e:\met-data\hhour';
%*************************************************************************
% LOAD DATA
 
%Campbell Sonic data
[ts,u_CS] = join_trace('squeeze(stats.RawData.AvgMinMax.Counts(1, 5+11, :))',st,en,'hc.mat',pth);  
[ts,v_CS] = join_trace('squeeze(stats.RawData.AvgMinMax.Counts(1, 5+17, :))',st,en,'hc.mat',pth);  
[ts,w_CS] = join_trace('squeeze(stats.RawData.AvgMinMax.Counts(1, 5+18, :))',st,en,'hc.mat',pth);  
[ts,T_CS] = join_trace('squeeze(stats.RawData.AvgMinMax.Counts(1, 5+19, :))',st,en,'hc.mat',pth);  

%Gill R2 data
[ts,u_Gill] = join_trace('squeeze(stats.AfterRot.AvgMinMax(1, 1, :))',st,en,'hc.mat',pth);  
[ts,v_Gill] = join_trace('squeeze(stats.AfterRot.AvgMinMax(1, 2, :))',st,en,'hc.mat',pth);  
[ts,w_Gill] = join_trace('squeeze(stats.AfterRot.AvgMinMax(1, 3, :))',st,en,'hc.mat',pth);  
[ts,T_Gill] = join_trace('squeeze(stats.AfterRot.AvgMinMax(1, 4, :))',st,en,'hc.mat',pth);  


if en > 730120 & st > 730120
   ts = ts + 365;
end
t = ts - GMT_to_PST + 1;				%convert to TDOY (PST)
ts = t + 365; clear t

% Conversion of voltages to u,v,w and T for CSAT3 sonic. 
% Calibration for analog outputs from CSAT3 manual (low range)
% each row contains slope (m s^-1 V^-1) and offset (m s^-1) for u, v, w, and T, respectively
sonic_poly = [6.5536 0; 6.5536 0; 1.6384 0; 6.5536 340];
% input data in counts, convert into mV

sonicIn = ([u_CS v_CS w_CS T_CS].*5000/2^15)';
% convert into volts
sonicIn = sonicIn/1000;
%get specific humidity (mass of water wapor/mass of wet air)
%from x (mmol of water wapor/mol of wet air) in fr_licor_h.m
%[co2,h2o,Tbench,Plicor] = fr_licor_calc_and_plot(740,[6 7 8 9],st);
%x = h2o;
%chi_mm =  x./(1 + x/1000);     % mmol/mol of wet air
% Convert chi_mm into chi (g/g of wet air)
% (Conversion from program H2O_conv.m)
%    from mmol/mol dry air to r (mixing ratio) g water vapour/g dry air
% assuming 0% H2O, air = 28.96257 g/mole, assuming 4% H2O = 29.68337 g/mole
%chi = chi_mm.*18.02./29.68337./1000;   %Stull,R.B. 1995. Met. Today for Scientists and Engineers p7
%chi = (6*10^(-3)*ones(length(sonicIn), 1))';
chi=1;
[sonicOut,Tair_v,sos] = fr_CSAT_calc(sonic_poly, sonicIn, chi);
Tair_CSAT = Tair_v;
Tair_Gill = T_Gill;
t = ts-2*365;

cup_3D_Gill = (u_Gill.^2 + v_Gill.^2 + w_Gill.^2).^0.5;
cup_3D_CSAT = (sonicOut(1,:).^2 + sonicOut(2,:).^2 + sonicOut(3,:).^2).^0.5;

