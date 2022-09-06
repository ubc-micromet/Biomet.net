%
%
%
%
% (c) Zoran Nesic		File created:		Apr  2, 1996
%				        Last modification:	Apr 17, 1997
%

P = 100.5;			% Barometric pressure [kPa]
v = [906 766 630 508 400.3 307.5 506.4 1086 1260 1439 1626 930 778 639 512 308];   % [mV]
[v,ind] = sort(v);
degC = [10 12 14 16 18 20 16  8 6 4 2 10 12 14 16 20];
degC = degC(ind);
T = 24;		  	                                %[degK]	
Td = degC;
e = 0.61365*exp(17.502*Td./(240.97+Td));        % [kPa]
Dv = 2164.5*e/(T+ 273.15);		                % [g/m^3]
p = polyfit(log(v),Dv,1);
figure(1)
er = polyval(p,log(v))-Dv;
disp(sprintf('Mean square error = %f',mean(er.^2)))
plot(Dv,er)
grid
title('Krypton calibration (S/N 1016)')
xlabel('(g/m^3)')
ylabel('Calibration error (g/m^3)')
figure(2)
plot( Dv, log(v),'o',   polyval(p,log(v)) , log(v)  )
grid
ylabel('Krypton output - log(mV)')
xlabel('Vapor density (g/m^3)')
disp(sprintf('Dv = (%6.6e)log(v) + (%6.6e)',p))
disp(sprintf('Dv = log(v/%6.6e)/(%6.6e)',exp(-p(2)/p(1)),1/p(1)))



P = 101.1;			% Barometric pressure [kPa]
v = [1085 960 834 713 599 494 397 311 239 177 120 956 711 598 493 397 314 242 179];   % [mV]
[v,ind] = sort(v);
degC = [2 4 6 8 10 12 14 16 18 20 22 4 8 10 12 14 16 18 20 ];
degC = degC(ind);
T = 24;		  	           %[degK]	
Td = degC;
e = 0.61365*exp(17.502*Td./(240.97+Td));   % [kPa]
Dv = 2164.5*e/(T+ 273.15);		           % [g/m^3]
p = polyfit(log(v),Dv,1);
figure(3)
er = polyval(p,log(v))-Dv;
disp(sprintf('Mean square error = %f',mean(er.^2)))
plot(Dv,er)
grid
title('Krypton calibration (S/N 1054)')
xlabel('(g/m^3)')
ylabel('Calibration error (g/m^3)')
figure(4)
plot( Dv, log(v),'o',   polyval(p,log(v)) , log(v)  )
grid
ylabel('Krypton output - log(mV)')
xlabel('Vapor density (g/m^3)')
disp(sprintf('Dv = (%6.6e)log(v) + (%6.6e)',p))
disp(sprintf('Dv = log(v/%6.6e)/(%6.6e)',exp(-p(2)/p(1)),1/p(1)))