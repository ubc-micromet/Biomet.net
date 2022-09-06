function [Px, f] = psd_met(x, nfft, Fs, noverlap, dflag, window)

%   PSD_MET  The meteorological version of PSD.  The default window
%       is the bell taper on P. 310 (Stull, 1988). 
%   It uses the Matlab PSD and divides Px with N to achieve Note 1.
%   
%   [Px, f] = psd_met(x, nfft, Fs, noverlap, dflag, window)
%
%   NOTE:
%
%   1. Var(x) = Sum(abs(Px) which equals to COV(x) if and only if window = Boxcar;
%
%   2. The default window in this program is the bell taper recommanded by
%       Stull (1988).
%  
%   3. For good frequency detection, people usually use Hanning window ( default
%       in Signal Processing Toolbox)
%
%   4.  Var(x) = 2.3*Sum(Fx.*abs(Px); in semilogx ((Log10(f))) presenttation.
%       The area under the curve here is 0.43!  Check this.
%
%   See also CSD, PSD, COHERE, TFE
%
%       Created on  09 Apr. 1997 by Paul Yang
%       Modified on 17 Apr. 1997 

n = nargin;
msg = nargchk(5,6,n);
disp(msg)

if (nargin < 6)
    window = sin_filt(nfft, 0.1);
end

if (nargin < 5)
    dflag = 'linear';
end

if (nargin < 4)
    noverlap = 0;
end

[Px, f] = psd(x, nfft, Fs, window, noverlap, dflag);

Px = Px * 2 / nfft;
