%
% KH2O S/N 1054 calibration
%
%   Date of calibration: May 12, 1997
%
%
% 

SN = 1054;                                      % Krypton serial number
P = 98.62;                                      % Barometric pressure [kPa]
v = [ 138  183 237.5 300 ...
      370  449 530 621 ...
      715  810 713 622 ...
      529  447 370 298 ...
      235  180 136];                            % [mV]
[v,ind] = sort(v);
Tdew =   [ 20 18 16 14 12 10 8 6 4 2 ...
          4  6  8 10 12 14 16 18 20];           % Dew point gen. temp.
Tdew = Tdew(ind);
T =    [27.37 27.39 27.67 27.72 27.74 ...
        27.87 28.02 28.14 28.34 28.02 ...
        27.96 27.89 27.87 27.80 27.76 ...
        27.58 27.50 27.31 27.56];               %[degC] Krypton air temp (thermocuple)
T = T(ind);        

e = 0.61365*exp(17.502*Tdew./(240.97+Tdew));    % [kPa]

Dv = 2164.5*e./(T+ 273.15);                     % [g/m^3]


%
% Polynomial fitting
%
p = polyfit(log(v),Dv,1);

%
% Plotting of the results
%
figure(1)
er = polyval(p,log(v))-Dv;
plot(Dv,er)
grid
title(sprintf('Krypton calibration (S/N %d)',SN))
xlabel('(g/m^3)')
ylabel('Calibration error (g/m^3)')

figure(2)
plot( Dv, log(v),'o',   polyval(p,log(v)) , log(v)  )
grid
title(sprintf('Krypton calibration (S/N %d)',SN))
ylabel('Krypton output - log(mV)')
xlabel('Vapor density (g/m^3)')
ax = axis;
text(10,6.5,sprintf('Dv = (%6.6e)log(v) + (%6.6e)',p))
text(10,6.3,sprintf('Dv = log(v/%6.6e)/(%6.6e)',exp(-p(2)/p(1)),1/p(1)))
text(10,6.1,sprintf('Mean square error = %f',mean(er.^2)))

