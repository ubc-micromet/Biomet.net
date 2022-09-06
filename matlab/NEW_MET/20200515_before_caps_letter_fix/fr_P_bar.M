function p = fr_p_bar(p_in,dz,T)
%
%   p = fr_p_bar(p_in,dz,T)
%
%   Parameter dz is used to correct the pressure for the difference in
%   hight between the place where the pressure is measured (Hut) and the
%   actual place where pressure correction has to be applied (LICOR box on the
%   tower). Ref: Beer, T. 1990, Applied Environmentric Meteorological Tables
%
%   Inputs:
%       p_in    pressure
%       dz      hight difference (m) between the pressure measurement and
%               the rest of the sensors (=tower hight). Default is dz=0.
%       T       temperature in degC (required when dz is used)
%
% (c) Zoran Nesic           File created:       May 7, 1997
%                           Last modification:  Apr 2, 1998
%

%
% Revisions:
%
%   Apr 2, 1998
%       -   converted p_bar.m to fr_p_bar.m. Changed inputs. 
%

ni = nargin;
if ni < 3                                   % all parameters are required
    error 'Missing required parameter(s)!'
end

R = 8.31451;                                % (J/(K mol)
M = 0.028965;                               % (kg/mol)
g = 9.81;                                   % (m/s2)
coeff1 = R / M / g;
p = p_in.* exp(-dz ./ coeff1 ./ ...
                (273.15 + T) );             % pressure correction


