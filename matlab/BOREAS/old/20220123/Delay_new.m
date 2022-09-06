function [d,xc] = delay(a,b,limits)
%
%   function [d,xc] = delay(a,b,limits)
%
%  Inputs:
%       a,b         input arrays
%       limits      the range of delays of interest (if limits=[]
%                   then use full range
%  Outputs:
%       d           delay
%       xc          crosscorrelation vector of 
%                   length = length(a) + length(b) - 1   
%
%
%  This procedure returns the delay of the sequence b
%  relative to sequence a. This procedure uses xcorr()
%  from the SignalProcessing toolbox.
%
% (c) Zoran Nesic                File created:          Jan 4, 1996
%                                Last modification:     Mar 2, 2000
%
% Revisions
%
% Mar 2, 2000
%   - xc = xcorr(a,b,max(abs(limits))); Added: ",max(abs(limits))" to limit xcorr

a = detrend(a);
b = detrend(b);
n = max([length(a) length(b)]);
m = min([length(a) length(b)]);

if nargin < 3
    limits = [-m m];
end

xc = xcorr(a,b,max(abs(limits)));

[j1,ind] = max(abs(xc)); 
sg = sign(xc(ind));
d = ind - n;

if d <= 0
    xc = xc(1:length(a)+length(b)-1);
    x1 = -(n-1);
    x2 = -(1-m);
else
    xc = xc(length(xc)-length(a)-length(b)+2:length(xc));
    x1 = 1-m;
    x2 = n-1;
end

limits = limits - x1 + 1;
n1 = limits(1):limits(2);

[j1,ind] = max(abs(xc(n1))); 
sg = sign(xc(n1(ind)));
d = n1(ind) - abs(x1) - 1;

if nargout == 0
    subplot(212)
    plot(x1:x2,xc,'g');
    ax = axis;
    axis([x1 x2 ax(3:4)])
    grid
    line([x1 x2],[j1  j1]*sg)
    line([ d d],ax(3:4))
    title('Crosscorrelation')
    xlabel('Delay')
    
    subplot(211)
    plot(b,'y')
    hold on
    plot(a,'r')
    hold off
    grid
    title(sprintf('Input signals: Second (yellow) signal lags for %d samples',d))
    xlabel('Sample')    
end

