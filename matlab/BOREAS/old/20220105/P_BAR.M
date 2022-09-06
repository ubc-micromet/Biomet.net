function p = p_bar(v,pp,dz,T)
%
%   p = p_bar(v,pp,dz)
%
%   This function returns barometric pressure for the given voltage (mV).
%   If parameter pp is given, it should contain the polynomial coefficients
%   for the linerization (pp = [a b] for p = a*mV + b). If pp is missing
%   the Vaisala barometer (UBC) will be used as a default.
%
%   Parameter dz is used to correct the pressure for the difference in
%   hight between the place where the pressure is measured (Hut) and the
%   actual place where pressure correction has to be applied (LICOR box on the
%   tower). Ref: Beer, T. 1990, Applied Environmentric Meteorological Tables
%
%   Inputs:
%       v       voltage in mV
%       pp      linearization coefficients for the pressure transducer.
%               (default is pp = [9.2 60] kPa)
%       dz      hight difference (m) between the pressure measurement and
%               the rest of the sensors (=tower hight). Default is dz=0.
%       T       temperature in degC (required when dz is used)
%
% (c) Zoran Nesic           File created:       May 7, 1997
%                           Last modification:  May 7, 1997
%

ni = nargin;
if ni == 3
    error 'Temperature is required for pressure correction!'
end
if ni < 3
    dz = 0;                                     % default hight
end
if ni < 2
    pp = [9.2 60];                              % default linearization polynomial
end
if ni < 1
    error 'Missing required parameter(s)!'
end

p = polyval(pp,v/1000);                         % linearization

if ni > 3
    R = 8.31451;                                % (J/(K mol)
    M = 0.028965;                               % (kg/mol)
    g = 9.81;                                   % (m/s2)
    coeff1 = R / M / g;
    p = p.* exp(-dz ./ coeff1 ./ (273.16 + T) );% pressure correction
end


