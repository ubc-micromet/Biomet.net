%-----------------------------------------------------------
%  Calculation of the sensitivity for CO2 measurements
%-----------------------------------------------------------

N = 1000;                         
Po = 101.3;
BarometricP = [ 97:99]';
Pgauge = [14.5];      
Pc = Po./(BarometricP - Pgauge);       % pressure correction
v = linspace(1100,1900,N);             % voltage (mV)
vc = Pc * v;                           % voltage (mv) corrected for the pressure

% LICOR constants for CO2

ac = 0.15719;
bc = 2.6034e-6;
cc = 9.5378e-9;
dc = -1.3589e-12;
ec = 8.3558e-17;

Tinternal = 39;
Tco = 36.1;
Tc = (Tinternal + 273)/(Tco + 273);

co2 = (ac * vc + bc * vc.^2 + cc * vc .^3 + dc * vc .^4 + ec * vc .^5) * Tc;

%coeff = polyfit(v( 0.6*N:N),co2(.6*N:N),1);

figure(1)
plot(v,co2)
title(sprintf('co2 vs voltage (Pb = %d:%d, Pg = %5.2f)',min(BarometricP),max(BarometricP),Pgauge))
xlabel('Voltage (mV)')
ylabel('CO2 (ppm)')
%axis([ 1700 3000 300 700])
grid

figure(2)
sense = zeros(1,N);
Vsense = zeros(1,N);
k = 2:N;
j = 1:3 ;
sense(j,k) = co2(j,k) - co2(j,k-1);
Vsense(k) = v(k) - v(k-1);
plot(co2(j,:)',[Vsense(:) Vsense(:) Vsense(:)] ./ sense(j,:)')
title(sprintf('Sensitivity of co2 measurements (Pb = %d:%d, Pg = %5.2f)',min(BarometricP),max(BarometricP),Pgauge))
xlabel('co2 absolute (ppm)')
ylabel ('Sensitivity (mV/ppm)')
grid

        


