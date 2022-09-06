%-----------------------------------------------------------
%  Calculation of the sensitivity for H2O measurements
%-----------------------------------------------------------

N = 1000;                         
Po = 101.3;
BarometricP = [97:99]';
Pgauge = 22.5;      
Pc = Po./(BarometricP - Pgauge);     % pressure correction
v = linspace(0,800,N);             % voltage (mV)
vc = Pc * v;                        % voltage (mv) corrected for the pressure

% LICOR constants for CO2

ah = 6.2491e-3;
bh = 2.9898e-6;
ch = 9.8957e-9;
dh = 0;
eh = 0;
Tinternal = 39;
Tho = 41.2;

Th = (Tinternal + 273)/(Tho + 273);
h2o = (ah * vc + bh * vc.^2 + ch * vc .^3 + dh * vc .^4 + eh * vc .^5) * Th;

%coeff = polyfit(v( 0.6*N:N),h2o(.6*N:N),1);

figure(1)
plot(v,h2o)
title(sprintf('h2o vs voltage (Pb = %d:%d, Pg = %5.2f)',min(BarometricP),max(BarometricP),Pgauge))
%title('h2o vs voltage (Pb = 93:95, Pg = 22.1)')
xlabel('Voltage (mV)')
ylabel('H2O (mmol/mol)')
%axis([ 1700 3000 300 700])
grid

figure(2)
sense = zeros(3,N);
Vsense = zeros(1,N);
k = 2:N;
j = 1:3 ;
sense(j,k) = h2o(j,k) - h2o(j,k-1);
Vsense(k) = v(k) - v(k-1);
plot(h2o(j,:)',[Vsense(:) Vsense(:) Vsense(:)]./ sense(j,:)')
title(sprintf('Sensitivity of h2o measurements (Pb = %d:%d, Pg = %5.2f)',min(BarometricP),max(BarometricP),Pgauge))
%title('Sensitivity of h2o measurements (Pb = 93:95, Pg = 22.1)')
xlabel('h2o absolute (mmol/mol)')
ylabel ('Sensitivity (mV/(mmol/mol))')
grid

        


