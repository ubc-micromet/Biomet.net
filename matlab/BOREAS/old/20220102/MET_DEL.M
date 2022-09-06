% ==================================================================
% July 9, 1994
%                   met_del.m
%
%   Test the influence of a passive filter on the group delay and
%  frequency response.
%
%   Rf - filter resistor
%   Cf - filter capacitor
%   Rl - sensor input impedance
%   T  - period of sampling
%
%             1/A                        (1 - exp(-TB/A))
%   G(s)= -----------   =>      G(z) = --------------------
%           s + B/A                      (z  - exp(-TB/A))
%
%

Rf = 234;   % [ohm]
Cf = 68e-6;  % [F]
Rl = 2e5;   % [ohm]
fs = 1000;    % [Hz]
T  = 1/fs;  % [sec]

x = Rl/Rf;
A = Rf*Cf;
B = 1 + 1/x;

num = [0   (1 - exp(-T*B/A))/B];
den = [1   -exp(-T*B/A)];


figure(1)
freqz(num,den)
[ h w ] = freqz(num,den);
mag = abs(h);
phi = angle(h);
figure(2)
grpdelay(num,den)

