%
%	Filter design for FRBC. 
%
%
%
% (c) Zoran Nesic           File created:       May 25, 1997
%                           Last modification:  Oct 12, 1997

% Revisions:
%   Oct 12, 1997
%       changed:
%           b = remez(No,F,M);
%       to
%           b = remez(No-1,F,M);
%

Fs = 20.833333;             % sampling rate (Hz)
No = 6;                     % oversampling factor
Fs1 = Fs * No;              % actual sampling rate

F = [0 .18 .28 1];          % filter frequency setup
M = [1  1   0.1 0];         % filter magnitude points
b = remez(No-1,F,M);        % filter desing
b = b/sum(b);               % normalize coefficients (gain = 1 at DC)

N = 128;                    % points to plot
figure(1)
clf
freqz(b,1,N,Fs1);           % plot the frequency response
subplot(211)                % zoom in
axis([0 2*Fs -20 2])        % on the magnitude plot
zoom on

disp(sprintf('\nSampling frequency:       %f',Fs))
disp(sprintf('Oversampling coeff:       %f',No))
disp(sprintf('Actual sampling freq.:    %f',Fs1))

% RC anti-aliasing filter design
C = 0.47e-6;                % capacitance
R = 6800;                   % resistance
f = 1/(2*pi*R*C);           % 3dB point
fs = 2*f;                   % sampling rate to avoid aliasing

[H,W] = freqs(1,[R*C 1],linspace(0,Fs1*2*pi,N));   % find freq. response
figure(2)
clf
plot(W/2/pi,20*log10(abs(H)))
grid
xlabel('Freq. (Hz)')
ylabel('Magnitude (dB)')
zoom on
axis([0 Fs1 -20 5])

disp(sprintf('\nRC filter design (anti-aliasing)'))
disp(sprintf('R = %e, C = %e, f = %e',R,C,f))
disp(sprintf('Sampling rate must be > %f',fs))