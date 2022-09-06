function [d,xc,lags] = fr_delay(a,b,MAX_LAG)
%
%   function [d,xc,lags] = fr_delay(a,b,MAX_LAG)
%
%  Inputs:
%       a,b         input arrays
%       MAX_LAG     [-MAX_LAG +MAX_LAG] useful range for the lags
%
%  Outputs:
%       d           delay
%       xc          crosscorrelation vector of 2*MAX_LAG-1 points
%       lags        vector of lags. Can be used for: plot(lags,xc)
%
%
%  This procedure returns the delay of the sequence b
%  relative to sequence a. This procedure uses UBC_xcorr()
%  from the old Matlab Signal Processing toolbox.
%
% (c) Zoran Nesic                File created:          Mar 29, 1998
%                                Last modification:     Jan 22, 2004

% Revisions:
%   Jan 22, 2004
%       - changed xcorr to ubc_xcorr (this file is a copy of the old Matlab
%         xcorr.m function) to maintain compatibility with between Matlab versions
%         5.3.1 and 6.x.  The new xcorr reversed the sign of the delay and the
%         order of coefficients
%


a = detrend(a);
b = detrend(b);

[xc,lags] = UBC_xcorr(a,b,MAX_LAG);

[j1,ind] = max(abs(xc)); 
d = lags(ind);


