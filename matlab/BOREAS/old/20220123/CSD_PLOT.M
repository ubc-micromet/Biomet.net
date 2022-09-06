function csd_plot(Flog, Pxd, covx, Fs, nfft, zu, loglogFlag, normFlag, csdFlag, titlex, xlabelx, ylabelx, axisx)

%   This program generates the standard plots the Pxy -- cospectral/spectral density
%       See examples on P316 by Stull (1988)
%
%   csd_avg(Flog, Pxd, covx, Fs, nfft, zu, loglogFlag, normFlag, csdFlag, titlex, xlabelx, ylabelx, axisx)
%
%   Inputs: (From csd_avg)
%       Pxd -- mean spectral/cospectral density
%       Flog -- mean frequency (Hz) 
%       covx -- Covariance of w & x OR Variance of x for PSD
%       Fs -- Sampling frequencey
%       nfft -- length of the window for CSD/PSD
%       zu -- the ratio of z to u (z/u)
%       Nlog -- average interval (default = 50)
%       loglogFlag -- flag of plotting loglog (~0) or semilog (0)
%       normFlag -- flag shows whether normalization by covx required (0) or not (~0)
%       csdFlag -- csd (0) or psd (~=0)
%       titlex -- the title of the figure
%       xlabelx -- the x_label of the figure
%       ylabelx -- the y_label of the figure
%       axisx -- the axis of the figure
%
%   Created on  16 Apr. 1997 by Paul Yang
%   Modified on 17 Apr. 1997

n = nargin;
msg = nargchk(5,13,n);
disp(msg)

l = length(Pxd);
if l <= 50
    PlotSymbal = 'o';
else
    PlotSymbal = '-';    
end


Pxd = Pxd * nfft / 2; % Back compute the Pxd from CSD -- see CSD_MET.m
Pxd = Pxd * 2 / Fs;  % Compute the Pxd's regarding to frequency (in frequency domain)

if csdFlag == 0
    Pxdp = real(Pxd);
else
    Pxdp = abs(Pxd);
end

Flogn = Flog * zu;

if loglogFlag == 0
    if normFlag == 0
        semilogx(Flog,Flog.*Pxdp/covx,Flog,Flog.*Pxdp/covx, PlotSymbal)
    else
        semilogx(Flog,Flog.*Pxdp,Flog,Flog.*Pxdp, PlotSymbal)
    end
else
    if normFlag == 0
        loglog(Flogn,Flog.*abs(Pxdp)/abs(covx),Flogn,Flog.*abs(Pxdp)/abs(covx), PlotSymbal)    
    else
        loglog(Flogn,Flog.*abs(Pxdp),Flogn,Flog.*abs(Pxdp), PlotSymbal)    
    end
end

if (nargin < 10)
    titlex = 'Cospectral analysis';
end

if (nargin < 11)
    xlabelx = 'f (Hz)';
end    

if (nargin < 12)
    ylabelx = 'cospectral density';
end

if (nargin < 13)
    axisx = [.01 1000 1e-8 10];
end  

title(titlex, 'fontsize',14)
xlabel(xlabelx, 'fontsize',14)
ylabel(ylabelx, 'fontsize',14)
axis(axisx)
line(axisx(1:2),[0 0])
if loglogFlag ~= 0
    pow = 10^(log10(abs(max(Pxd)))-3);
    if csdFlag == 0
        line([10  10000], [pow pow * 10^(-4/3*3)])
        text(100, 100*pow*10^(-1*3),'-4/3')
    else
        line([10  10000], [pow pow * 10^(-2/3*3)])
        text(100, 100*pow*10^(-1*3),'-2/3')
%         line([.01  10], [pow pow * 10^(-2/3*3)])
%         text(.1, .3*10^(-2/3*3),'-2/3')
    end
end