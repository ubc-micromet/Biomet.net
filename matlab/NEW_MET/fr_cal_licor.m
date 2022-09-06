function [c_cal,h_cal] = fr_cal_licor(num, c_cal_ppm, c_zero_off_mV, c_mV, h_mV, To_mV, Plicor_mV,h_zero_off_mV,h_cal_mmol)
%
%  [c_cal,h_cal] = fr_cal_licor(num, c_cal_ppm, c_zero_off_mV, c_mV, h_mV, To_mV, Plicor_mV,h_zero_off_mV,h_cal_mmol)
%
%   LI-COR 6262 calibration program.
%
%   Inputs:
%       num             - LI-COR serial number (see Licor.m)
%       c_cal_ppm       - calibration tank concentration in ppm
%       c_zero_off_mV   - co2 offset in milivolts
%       c_mV            - co2 voltage as measured during co2 calibration
%       h_mV            - h2o voltage as measured during h2o calibration
%       To_mV           - optical bench temperature signal (mV)
%       Plicor_mV       - LI-COR pressure sensor voltage (mV)
%       h_zero_off_mV   - h2o offset in milivolts
%       h_cal_mmol      - water vapor calibration value in mmol/mol of wet air
%
%   Outputs:
%       c_cal           - co2 calibration constant (range: 0.0-1.0)
%       h_cal           - h2o calibration constant (range: 0.0-1.0)
%
%
% (c) Zoran Nesic       File created:       Dec  2, 1997
%                       Last modification:  Jun 3, 2010
%

% Revisions:
%   Jun 1, 2010
%       - modified check for LI-7000 # from 7000 to 700x to handle
%         changes in h2o analog span configuration
%   Mar 16, 2007
%       -modified so function can handle LI-7000 analog output (i.e. to a
%       DAQbook) using a linear calibration.
%    Sep 13, 1998
%       - vectorization of all calculations. This program can now be used
%         to recalculate calibration gains using multiple calibrations (see
%         cal_pl.m)
%   Jun 21, 1998
%       - made H2O calibration data optional
%   Jun 17, 1998
%       -   implemented h2o calibration
%

if ~exist('h_zero_off_mV') | ~exist('h_cal_mmol')
    h_zero_off_mV = [];
end

N = 2000;                               % max points

% Mar 16/07 modified for LI-7000 using analog out (Nick) with a linear
% conversion from mV to ppm

% voltage_co2 = linspace(0,4000,N);       % voltage range for co2 (mV)
% voltage_h2o = linspace(0,2000,N);       % voltage range for h2o (mV)

if num > 7000 & num <= 7999
    voltage_co2 = linspace(0,5000,N);       % voltage range for co2 (mV)
    voltage_h2o = linspace(0,5000,N);       % voltage range for h2o (mV)
else
    voltage_co2 = linspace(0,4000,N);       % voltage range for co2 (mV)
    voltage_h2o = linspace(0,2000,N);       % voltage range for h2o (mV)
end

[cp,hp,Tc,Th,pp]...
        = licor(num);                   % get LI-COR calibration polynomials
%hp      = [ 0 0 hp];                   % extend h2o poly to fifth order
c       = polyval(cp,voltage_co2);      % get co2 values for the given voltage
h       = polyval(hp,voltage_h2o);      % get h2o values for the given voltage
% cpinv   = polyfit(c,voltage_co2,5);     % find inverse co2 poly (5th order)
% hpinv   = polyfit(h,voltage_h2o,5);     % find inverse h2o poly (5th order)

% Mar16/07: modified for LI-7000
if num > 7000 & num <= 7999
    cpinv   = polyfit(c,voltage_co2,1);     % find inverse co2 poly (linear)
    hpinv   = polyfit(h,voltage_h2o,1);     % find inverse h2o poly (linear)
else
  cpinv   = polyfit(c,voltage_co2,5);     % find inverse co2 poly (5th order)
  hpinv   = polyfit(h,voltage_h2o,5);     % find inverse h2o poly (5th order)
end
    
Plicor  = polyval(pp,Plicor_mV);        % calculate LI-COR pressure
To      = polyval([0.01221 0],To_mV);   % calculate LI-COR optical bench temperature

% co2_v   = ...
%         convertCO2_to_voltage( ...
%             cpinv,c_cal_ppm, ...
%             Tc,Plicor,To);              %

% Mar 16/07: modified for Li-7000
if num > 7000 & num <= 7999
    co2_v   = c_cal_ppm.*cpinv(1)-cpinv(2);
else
    co2_v   = ...
        convertCO2_to_voltage( ...
            cpinv,c_cal_ppm, ...
            Tc,Plicor,To);  
end

c_cal   = co2_v./(c_mV - c_zero_off_mV);

if isempty(h_zero_off_mV)
    h_cal = NaN;
else
    h2o_v   = ...
        convertH2O_to_voltage( ...
            hpinv,h_cal_mmol, ...
            Th,Plicor,To);              %

    h_cal   = h2o_v./(h_mV - h_zero_off_mV); %
end


%=========================================================================
% Local functions
%=========================================================================


%=========================================================================
% convertCO2_to_voltage
%=========================================================================
function co2_v = convertCO2_to_voltage(cpinv,c_cal_ppm,Tc,Plicor,To)

c1 = c_cal_ppm ./ ( (To + 273.16)./(Tc + 273.16) );
co2_v = polyval(cpinv,c1)./( 101.3 ./ Plicor);

%=========================================================================
% convertH2O_to_voltage
%=========================================================================
function h2o_v = convertH2O_to_voltage(hpinv,h_cal_mmol,Th,Plicor,To)

h1 = h_cal_mmol ./ ( (To + 273.16)./(Th + 273.16) );
h2o_v = polyval(hpinv,h1)./( 101.3 ./ Plicor).^0.9;



