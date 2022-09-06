function [u,er,ei,es] = pi_reg(y,dt,y_set,ei,es,Ki,Ti,Tt,Ulimits)
%
%   PI_reg  - simulation of a PI regulator with anti-windup
%
%   parameters:
%       y       - current output
%       dt      - sampling time (s)
%       y_set   - set point for the output
%       ei      - integrator value (from the previous step)
%       es      - control output integrated error (for anti-windup)
%       Ki      - proportional gain
%       Ti      - integrator time constant (s)
%       Tt      - anti-windup time constant(s)
%       Ulimits - actuator saturation points (Ulimits(1) = min, Ulimits(2) = max)
%   Output
%       u       - control signal
%       er      - error signal (yset-y)
%       ei      - integrator value
%       es      - integrated actuator saturation error
%
% (c) Zoran Nesic           File created:       Jan 11, 1999
%                           Last modification:  Jan 11, 1999
%
%
    er = y_set-y;
    ei = ei - er + es/Tt;
    v = Ki * (er + ei * dt / Ti);
    if v > Ulimits(2)
        u = Ulimits(2);
    elseif v < Ulimits(1)
        u = Ulimits(1);
    else
        u = v;
    end
    es = u - v;


