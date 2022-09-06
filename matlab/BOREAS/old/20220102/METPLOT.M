function x = metPlot(Date1, Time1, w, c, h, r, u, v, T, Pb, Pg)
%================================================
% Aug 15, 1994
%
%       metPlot.m
%
%   This function plots the 9 traces from Solent.
%   Figure #1:  (w,co2,h2o,rho)
%   Figure #2:  (u,v,T,Pbarometric, Pgauge)
%
%   Inputs:
%       Date1,  string showing the date of the measurements
%       Time1,  number showing the starting time of the measurements
%               in form: hhH, hh - hour, H - first or second half)
%       Input traces in the following order:
%           w,co2,h2o,Rho,u,v,T,Pbarometric, Pgauge
%           
%
hhourLen = 37500;
hours = fix( Time1 / 10 );
time = linspace( 0, 30 * length(w) / hhourLen, length(w) ) + (Time1 - hours * 10 - 1) * 30;
if mean(time) > 30
    t1 = 30;
    t2 = 60;
else
    t1 = 0;
    t2 = 30;
end

figure(1)
orient tall
clg

subplot(4,1,1)
plot(time,w)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('w [m/s]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

subplot(4,1,2)
plot(time,c)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('CO2 [ppm]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

subplot(4,1,3)
plot(time,h)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('H2O [mmol/mol]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

subplot(4,1,4)
plot(time,r)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('Rho [g/m^3]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))


figure(2)
orient tall
clg

subplot(5,1,1)
plot(time,u)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('u [m/s]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

subplot(5,1,2)
plot(time,v)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('v [m/s]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

subplot(5,1,3)
plot(time,T)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('Temperature [deg C]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

subplot(5,1,4)
plot(time,Pb)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('P barometric [kPa]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

subplot(5,1,5)
plot(time,Pg)
a = axis;
axis([ t1 t2 a(3) a(4)])
grid
xlabel('Time [min]')
ylabel('P gauge [kPa]')
title(sprintf('Date: %s, Time: %d hours',Date1,hours))

