%
%   lic_off.m
%
%   Offset and Gain selection for co2 and h2o
%
%
%
%  (c) Zoran Nesic                          File created:       May 17, 1996
%                                           Last modification:  May 17, 1996
%
Lnum = 791;         % LICOR serial number
N = 1024;           % points to plot
Pb = 94;            % barometric pressure
Pg = 16.3;          % gauge pressure
CalConst = 0.90;    % calibration constant
T = 40;             % optical bench temperature
Gh = 8;             % hi gain
Gl = 5;             % low gain

[cp,hp,Tc,Th] = licor(Lnum);
%
% co2
%
offset = 1222;      % offset in milivolts
v = linspace(0,2500,1024);
c = licor_c(cp,Tc,Pb,Pg,T,0,CalConst,v,'m');
figure(1)
plot(v,c)
line([offset offset+5000/Gh],[230 230],'linewidth',2)
line([offset offset+5000/Gl],[210 210],'linewidth',2)
grid
title(sprintf('LICOR-%d co2 for: Pb = %4.1f Pg = %4.1f T = %4.1f ',Lnum,Pb,Pg,T))
xlabel('Voltage (mV)')
ylabel('co2 (ppm)')

figure(2)
c = licor_c(cp,Tc,Pb,Pg,T,0,CalConst,v,'g');
plot(v,c)
line([offset offset+5000/Gh],[230 230],'linewidth',2)
line([offset offset+5000/Gl],[210 210],'linewidth',2)
grid
title(sprintf('LICOR-%d co2 for: Pb = %4.1f Pg = %4.1f T = %4.1f ',Lnum,Pb,Pg,T))
xlabel('Voltage (mV)')
ylabel('co2 (mg/m^3)')

%
% h2o
%
offset = 0;      % offset in milivolts
v = linspace(0,1600,1024);
h = licor_h(hp,Th,Pb,Pg,T,0,CalConst,v,'m');
figure(3)
plot(v,h)
line([offset offset+5000/Gh],[1.5 1.5],'linewidth',2)
line([offset offset+5000/Gl],[1 1],'linewidth',2)
grid
title(sprintf('LICOR-%d h2o for: Pb = %4.1f Pg = %4.1f T = %4.1f ',Lnum,Pb,Pg,T))
xlabel('Voltage (mV)')
ylabel('h2o (mmol/mol)')

h = licor_h(hp,Th,Pb,Pg,T,0,CalConst,v,'g');
figure(4)
plot(v,h)
line([offset offset+5000/Gh],[1.5 1.5],'linewidth',2)
line([offset offset+5000/Gl],[1 1],'linewidth',2)
grid
title(sprintf('LICOR-%d h2o for: Pb = %4.1f Pg = %4.1f T = %4.1f ',Lnum,Pb,Pg,T))
xlabel('Voltage (mV)')
ylabel('h2o (g/m^3)')


