P = 99.5;          % Barometric pressure [kPa]
v = [1400 1175 970 780 612 469 350 252 175 118 175 252 348 467 610 775 ...
965 1170 1390];   % [mV]
[v,ind] = sort(v);
degC = [2 4 6 8 10 12 14 16 18 20 18 16 14 12 10 8 6 4 2];
degC = degC(ind);
T = 24;                                         %[degK] 
Td = degC;
e = 0.61365*exp(17.502*Td./(240.97+Td));        % [kPa]

Dv = 2164.5*e/(T+ 273.15);                      % [g/m^3]
p = polyfit(log(v),Dv,1);
figure(1)
er = polyval(p,log(v))-Dv;
disp(sprintf('Mean square error = %f',mean(er.^2)))
plot(Dv,er)
grid
title('Krypton calibration (S/N 1276)')
xlabel('(g/m^3)')
ylabel('Calibration error (g/m^3)')
figure(2)
plot( Dv, log(v),'o',   polyval(p,log(v)) , log(v)  )
grid
ylabel('Krypton output - log(mV)')
xlabel('Vapor density (g/m^3)')
disp(sprintf('Dv = (%6.6e)log(v) + (%6.6e)',p))
disp(sprintf('Dv = log(v/%6.6e)/(%6.6e)',exp(-p(2)/p(1)),1/p(1)))



