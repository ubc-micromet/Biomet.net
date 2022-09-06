function win = sin_filt(N,p)

%   SIN_FILT  The bell taper recommanded on P. 310 (Stull, 1988).
%   It returns the N-point window in a column vector.
%   This is the default window for CSD_MET and PSD_MET.
%
%   Syntex:
%       win = sin_filt(N,p)
%   
%   where 
%           N is the length of the taper.
%           p is the releative length of the signal affected by the tapering
%               The default is 0.1
%      
%   Created on  09 April 1997 by Paul Yang
%   Modified on 16 April 1997
%   Revisions:  Jan 26, 2000   E.Humphreys
%               -put in 'round' function to ensure subscript indices are integer values

if nargin < 2
    p = 0.1;
end
win = ones(1,N);
k = [1:p*N round((1-p)*N):N];
win(k) = sin(5*pi*k/N).^2;

