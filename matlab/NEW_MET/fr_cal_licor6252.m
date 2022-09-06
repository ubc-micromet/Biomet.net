function [c_cal] = fr_cal_licor6252(num,c_cal_ppm,c_zero_off_mV,c_mV,To_mV,Pgauge_mV,Pgauge_poly,Pbarometric)
%
%  [c_cal] = fr_cal_licor6252(num,c_cal_ppm,c_zero_off_mV,c_mV,To_mV,Pgauge_mV,Pgauge_poly,Pbarometric)
%
%   LI-COR 6252 calibration program.
%
%   Inputs:
%       num             - LI-COR serial number (see Licor.m)
%       c_cal_ppm       - calibration tank concentration in ppm
%       c_zero_off_mV   - co2 offset in milivolts
%       c_mV            - co2 voltage as measured during co2 calibration
%       To_mV           - optical bench temperature signal (mV)
%       Pgauge_mV       - Gauge pressure (mV)
%       Pgauge_poly     - Polynomial for gauge pressure in kPa
%       Pbarometric     - Barometric pressure in kPa
%
%   Outputs:
%       c_cal           - co2 calibration constant (range: 0.0-1.0)
%
%   Note: h_cal is not calcultated on LI-6252 (see fr_cal_licor code)
%
% (c) dgg               File created:       May 6, 2003
%

% Revisions:

N = 2000;                               % max points
voltage_co2 = linspace(0,4000,N);       % voltage range for co2 (mV)

[cp,hp,Tc,Th,pp]...
        = licor(num);                   % get LI-COR calibration polynomials
c       = polyval(cp,voltage_co2);      % get co2 values for the given voltage
cpinv   = polyfit(c,voltage_co2,5);     % find inverse co2 poly (5th order)

Pgauge  = polyval(Pgauge_poly, Pgauge_mV); % calculate Pgauge in kPa
Plicor  = Pbarometric - Pgauge;            % calculate Plicor in kPa

To      = polyval([0.01221 0],To_mV);   % calculate LI-COR optical bench temperature

co2_v   = ...
        convertCO2_to_voltage( ...
            cpinv,c_cal_ppm, ...
            Tc,Plicor,To);              

c_cal   = co2_v./(c_mV - c_zero_off_mV); 

%=========================================================================
% Local functions
%=========================================================================

%=========================================================================
% convertCO2_to_voltage
%=========================================================================
function co2_v = convertCO2_to_voltage(cpinv,c_cal_ppm,Tc,Plicor,To)

c1 = c_cal_ppm ./ ( (To + 273.16)./(Tc + 273.16) );
co2_v = polyval(cpinv,c1)./( 101.3 ./ Plicor);


