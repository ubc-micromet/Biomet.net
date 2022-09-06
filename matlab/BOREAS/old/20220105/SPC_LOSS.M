function [x,n] = spc_loss(Pc,Fx,covWC,F)
%
% inputs:
%
%   Pc      -   cospectrum (non-filtered data)
%   Fx      -   frequency vector
%   covWC   -   covariance
%   F       -   cuttoff frequency
%
% outputs:
%
%   n       -   number of frequency points [ lenght(Fx > F) ]
%   x       -   relative variance for Fx > F (0.0 to 1.0)
%
% (c) Zoran Nesic           File created:             , 1995
%                           Last modification:  May 15, 1997
%

% Revisions
%
%   May 15, 1997
%       Program changed so it can be used with our new versions of
%       csd_met.m and psd_met.m (see below)
%

if nargin < 4
    error Too few arguments!
else
    % new version of the calculations (May 15, 1997)
    indF = find(Fx > F);
    n = length(indF);    
    x = sum(real(Pc(indF)))/covWC;
%
%   Changed on May 15, 1997
%    Fs = 20.83/2;
%    indF = find(Fx > F);
%    n = length(indF);
%    x = sum(real(Pc(indF)))/length(indF)/covWC*Fs;
end