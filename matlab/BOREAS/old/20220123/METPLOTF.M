function x = metPlotf(Date1, Time1, w, c, h, r, u, v, T, Pb, Pg, Fs)
%================================================
% Aug 15, 1994
%
%       metPlotf.m
%
%   This function plots power spectrums of the Solent signals.
%   Figure #1:  (w,co2,h2o,rho,T)
%   Figure #2:  (u,v,Pbarometric, Pgauge)
%
%   Inputs:
%       Date1,  string showing the date of the measurements
%       Time1,  number showing the starting time of the measurements
%               in form: hhH, hh - hour, H - first or second half)
%       Input traces in the following order:
%               w,co2,h2o,Rho,u,v,T,Pbarometric, Pgauge
%       Fs      Sampling frequency
%
hhourLen = 37500;
hours = fix( Time1 / 10 );
time = linspace( 0, 30 * length(w)/ hhourLen, length(w) ) + (Time1 - hours * 10 - 1) * 30;

% Calculate the power densities

[tmp,F] = spectrum(w,1024,[],[],Fs);
Pw = F .* tmp(:,1);
[tmp,F] = spectrum(c,1024,[],[],Fs);
Pc = F .* tmp(:,1);
[tmp,F] = spectrum(h,1024,[],[],Fs);
Ph = F .* tmp(:,1);
[tmp,F] = spectrum(r,1024,[],[],Fs);
Pr = F .* tmp(:,1);
[tmp,F] = spectrum(T,1024,[],[],Fs);
Pt = F .* tmp(:,1);
[tmp,F] = spectrum(u,1024,[],[],Fs);
Pu = F .* tmp(:,1);
[tmp,F] = spectrum(v,1024,[],[],Fs);
Pv = F .* tmp(:,1);
[tmp,F] = spectrum(Pb,1024,[],[],Fs);
Ppb =F .*  tmp(:,1);
[tmp,F] = spectrum(Pg,1024,[],[],Fs);
Ppg =F .*  tmp(:,1);

figure(1)
orient tall
clg

subplot(2,2,1)
loglog(F,Pw)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('W - f*S(f)')

subplot(2,2,2)
loglog(F,Pc)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('co2 - f * S(f)')

subplot(2,2,3)
loglog(F,Ph)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('h2o - f * S(f)')

subplot(2,2,4)
loglog(F,Pr)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('Rho - f * S(f)')

figure(2)
orient tall
clg

subplot(2,2,1)
loglog(F,Pt)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('Temperature - f * S(f)')

subplot(2,2,2)
loglog(F,Pu)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('u - f * S(f)')

subplot(2,2,3)
loglog(F,Pv)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('v - f * S(f)')

subplot(2,2,4)
loglog(F,Ppg)
grid
axis([.01 100 .0001 100])
title(sprintf('Date:%s    Time:%d hours',Date1,hours))
xlabel('Frequency [Hz]')
ylabel('Pgauge - f * S(f)')


