%
% file: FRBC_GEN.M
%
%
%   This program is used to calculate the required duty-cycle for the
%   genarator.
%
%
% (c) Zoran Nesic                   File created:       Dec  9, 1996
%                                   Last modification:  Dec  9, 1996
%
gal_per_L = 4;              % gallons per liter
P   = 200;                  % Required power (W)
V   = 12;                   % DC voltage (V)
Pg  = 3000;                 % Generator power
ug  = 0.5;                  % battery charger efficiency
F   = 5 * gal_per_L/ 8.4;   % Fuel per hour of work (L)

DutyCycle   = P / (Pg * ug);         % Generator duty-cycle
Tweekly     = DutyCycle * 7 * 24;    % Gen. run time per week (h)
Fweekly     = F * Tweekly;           % Fuel per week (L)

fprintf('\n\nGenerator duty-cycle:   %6.3f (%s)\n',DutyCycle*100,'%');
fprintf('Run per week:           %6.3f (h)\n',Tweekly);
fprintf('Fuel per week:          %6.3f (L) or %6.3f (gal)\n\n\n',Fweekly,Fweekly/gal_per_L);
