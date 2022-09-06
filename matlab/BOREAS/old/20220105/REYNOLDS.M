%       This function plots the flow rate versus the diameter of a sampling tube
%       with constant Reynolds number


Re(1)     = 2000;
Re(2)     = 4000;
Re(3)     = 1000;
Re(4)     = 3000;

D       = [.003:.0001:.010];
visc    = 0.00001461;            % kinematic molacular viscosity of air
f = zeros(length(D),length(Re));
f(:,1)       = 1/4  * pi * D'/visc*0.0000167*Re(1);            %        1L/min = 1.67*10^(-5) m^3/s
f(:,2)       = 1/4  * pi * D'/visc*0.0000167*Re(2);
f(:,3)       = 1/4  * pi * D'/visc*0.0000167*Re(3);
f(:,4)       = 1/4  * pi * D'/visc*0.0000167*Re(4);



plot(D*1000,f),grid
title(['Pump Flow Rate Versus Tubing Diameter '])
xlabel('Diameter   [mm]')
ylabel('Flow Rate   [ L/min ]')
text(max(D)*1000, max(f(:,1)),['Re = ' num2str(Re(1)) ])       %  ...*1000, to convert from m to mm
text(max(D)*1000, max(f(:,2)),['Re = ' num2str(Re(2)) ])
text(max(D)*1000, max(f(:,3)),['Re = ' num2str(Re(3)) ])
text(max(D)*1000, max(f(:,4)),['Re = ' num2str(Re(4)) ])


