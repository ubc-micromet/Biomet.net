function [Pxy, f] = csd_met(x, y, nfft, Fs, noverlap, dflag, window)

%   CSD_MET  The meteorological version of CSD.  The default window
%       is the bell taper on P. 310 (Stull, 1988). 
%   It uses the Matlab CSD and divides Pxy by nfft to achieve Note 1.
%   
%   [Pxy, f] = csd_met(x, y, nfft, Fs, noverlap, dflag, window)
%
%   NOTE:
%
%   1. Cov(xy) = Sum(real(Pxy)), which equals to Cov(x, y) if and only if
%       window = Boxcar; 
%
%     This covariance may not equal to the one calculated with COV(x,y)
%       because of the windowing operation in CSD.  However, it is okay
%       to use for cospectral analysis.
%  
%   2. The default WINDOW here is the bell taper recommanded by Stull (1988).
%
%   3. For good frequency detection, people usually use Hanning window (default
%       in the Signal Processing Toolbox
%
%   4. Cov(xy) = 2.3*Sum(Fx.*real(Pxy)); in semilogx((Log10(f))) presentation.
%       The area under the curve here is 0.43! CHECK THIS.
%
%   5. Usual values for the signals sampled by Gill R2 (20.83Hz) are:
%           nfft        = 2^14 samples (~13min)
%           length(x)   = 2^17 samples (~1.75hours)
%
%   See also CSD, PSD, COHERE, TFE
%
%       Created on  09 Apr. 1997 by Paul Yang
%       Modified on 14 May. 1997 
%

% Revisions:
%       May 14, 1997
%               Added more comments into the header (Note 5)
%

n = nargin;
msg = nargchk(6,7,n);
disp(msg)

if (nargin < 7)
    window = sin_filt(nfft, 0.1);
end

if (nargin < 6)
    dflag = 'linear';
end

if (nargin < 5)
    noverlap = 0;
end

[Pxy, f] = csd(x, y, nfft, Fs, window, noverlap, dflag);

Pxy = Pxy * 2 / nfft;